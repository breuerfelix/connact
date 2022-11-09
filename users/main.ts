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
const routePrefix = "/user";

const db = new Surreal(dbURL, null);
await db.signin({ user, pass });
await db.use(namespace, database);

const app = new Application();
app.use(oakCors({ origin: "*" }));
const router = new Router();

function res(ctx: any, code: number, body: any) {
  ctx.response.status = code;
  ctx.response.body = body;
}

async function findUser(db: Surreal, username: string) {
  const found = await db.query(
    "SELECT * FROM user WHERE id = $id",
    { id: "user:" + username },
  );

  return found[0].result;
}

router.get(`${routePrefix}/:username?`, async (ctx) => {
  const { username } = ctx.state.token;
  const targetUser = ctx.params.username || username;

  const users = await findUser(db, targetUser);
  if (users.length < 1) {
    return res(ctx, 400, "user not found");
  }
  const user = users[0];

  // you want your own data
  if (username == targetUser) {
    return res(ctx, 200, user);
  }

  // check if user is allowed to view desired user
  if (
    !user.contacts ||
    user.contacts.length < 1 ||
    !user.contacts.includes(`user:${username}`)
  ) {
    return res(ctx, 401, "the user requested has not added you");
  }

  // TODO only send data allowed to view
  res(ctx, 200, user);
});

router.post(routePrefix, async (ctx) => {
  const data = await ctx.request.body({ type: "json" }).value;
  const { username } = ctx.state.token;

  if ((await findUser(db, username)).length > 0) {
    return res(ctx, 400, "username already exists");
  }

  // TODO only set desired data
  const created = await db.create("user:" + username, {
    ...data,
    // username cannot be overridden
    username,
  });

  res(ctx, 200, created);
});

router.put(routePrefix, async (ctx) => {
  const data = await ctx.request.body({ type: "json" }).value;
  const { username } = ctx.state.token;

  const users = await findUser(db, username);
  if (users.length < 1) {
    return res(ctx, 400, "user not found");
  }

  const user = users[0];
  // username cannot be changed
  // TODO only set desired data
  const updated = await db.change(user.id, { ...data, username });
  res(ctx, 200, updated);
});

router.delete(routePrefix, async (ctx) => {
  const { username } = ctx.state.token;
  const deleted = await db.delete("user:" + username);
  res(ctx, 200, deleted);
});

app.use(async (ctx, next) => {
  try {
    await next();
  } catch (e) {
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
