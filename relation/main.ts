import { Application, oakCors, Router, Surreal, verify } from "./deps.ts";

const getEnv = Deno.env.get;
const getEnvOrDie = (env: string): string => {
  const value = getEnv(env);
  if (!value) {
    console.log("env not found", env);
    Deno.exit(1);
  }

  return value;
};

const port = Number(getEnv("PORT")) || 80;
const dbURL = getEnvOrDie("DB_URL");
const user = getEnvOrDie("DB_USER");
const pass = getEnvOrDie("DB_PASS");
const namespace = getEnvOrDie("DB_NAMESPACE");
const database = getEnvOrDie("DB_DATABASE");
const secret = getEnvOrDie("JWT_SECRET");

const algorithm = "HS256";
const routePrefix = "/relation";

const db = new Surreal(dbURL, null);
await db.signin({ user, pass });
await db.use(namespace, database);

const app = new Application();
app.use(oakCors({ origin: "*" }));
const router = new Router();

function addToList(list: string[], item: string): string[] {
  const newList = list || [];
  if (!newList.includes(item)) newList.push(item);
  return newList;
}

function removeFromList(list: string[], item: string): string[] {
  if (!list || list.length < 1) return [];
  return list.filter((x: string) => x != item);
}

function res(ctx: any, code: number, body: any) {
  ctx.response.status = code;
  ctx.response.body = body;
}

async function findUser(db: Surreal, username: string) {
  const found = await db.query(
    "SELECT * FROM user WHERE id = $id",
    { id: "user:" + username },
  );

  const users = found[0].result;
  if (!users || users.length < 1) return null;
  return users[0];
}

router.post(`${routePrefix}/:username`, async (ctx) => {
  const { username } = ctx.state.token;
  const targetUser = ctx.params.username;

  if (!targetUser) {
    return res(ctx, 401, "no username given to add");
  }

  if (username == targetUser) {
    return res(ctx, 401, "you cannot add yourself");
  }

  const userToAdd = await findUser(db, targetUser);
  if (!userToAdd) return res(ctx, 400, "user not found");

  const ownUser = await findUser(db, username);
  if (!ownUser) return res(ctx, 400, "you do not exist");

  if (ownUser.contacts?.includes(userToAdd)) {
    return res(ctx, 400, "user already added");
  }

  if (
    ownUser.pending?.includes(userToAdd.username) &&
    userToAdd.requested?.includes(ownUser.username)
  ) {
    // you just accept the request
    ownUser.contacts = addToList(ownUser.contacts, userToAdd.id);
    userToAdd.contacts = addToList(userToAdd.contacts, ownUser.id);

    // clear pending and requested
    ownUser.pending = ownUser.pending.filter((x: string) =>
      x != userToAdd.username
    );
    userToAdd.requested = userToAdd.requested.filter((x: string) =>
      x != ownUser.username
    );

    // update users
    await db.change(userToAdd.id, userToAdd);
    const updated = await db.change(ownUser.id, ownUser);
    // return updated own user
    res(ctx, 200, updated);
    return;
  }

  // user requests the other user to be contacts
  ownUser.requested = addToList(ownUser.requested, userToAdd.username);
  userToAdd.pending = addToList(userToAdd.pending, ownUser.username);

  // update target user aswell
  await db.change(userToAdd.id, userToAdd);
  const updated = await db.change(ownUser.id, ownUser);

  // return updated own user
  res(ctx, 200, updated);
});

router.delete(`${routePrefix}/:username`, async (ctx) => {
  const { username } = ctx.state.token;
  const targetUser = ctx.params.username;

  if (!targetUser) {
    return res(ctx, 401, "no username given to add");
  }

  if (username == targetUser) {
    return res(ctx, 401, "cannot delete own user");
  }

  const ownUser = await findUser(db, username);
  if (!ownUser) return res(ctx, 400, "own user not found");

  const userToRemove = await findUser(db, targetUser);
  if (!userToRemove) return res(ctx, 400, "target user not found");

  ownUser.contacts = removeFromList(ownUser.contacts, userToRemove.id);
  userToRemove.contacts = removeFromList(userToRemove.contacts, ownUser.id);

  ownUser.pending = removeFromList(ownUser.pending, userToRemove.username);
  ownUser.requests = removeFromList(ownUser.requests, userToRemove.username);

  userToRemove.pending = removeFromList(userToRemove.pending, ownUser.username);
  userToRemove.requests = removeFromList(
    userToRemove.requests,
    ownUser.username,
  );

  // update target user aswell
  await db.change(userToRemove.id, userToRemove);
  const updated = await db.change(ownUser.id, ownUser);

  // return updated own user
  res(ctx, 200, updated);
});

app.use(async (ctx, next) => {
  try {
    await next();
  } catch (e) {
    console.error(e);
    res(ctx, 500, e.toString());
  }
});

app.use(async (ctx, next) => {
  const header = ctx.request.headers.get("authorization");
  const unauthCode = 401;
  if (!header) {
    return res(ctx, unauthCode, "authorization header missing");
  }

  const splitted = header.split(" ");
  if (splitted.length != 2) {
    return res(ctx, unauthCode, "authorization header wrong format");
  }

  const token = splitted[1];
  const data = await verify(token, secret, algorithm);
  if (!data.username) {
    return res(ctx, unauthCode, "username not found in token");
  }

  ctx.state.token = data;
  await next();
});

app.use(router.allowedMethods());
app.use(router.routes());

app.addEventListener("listen", () => {
  console.log(`Listening on: localhost:${port}`);
});

await app.listen({ port });
