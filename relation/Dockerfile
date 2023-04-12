FROM denoland/deno:alpine-1.32.1

EXPOSE 80
WORKDIR /app

COPY . .
RUN chown -R deno:deno /app

USER deno

RUN deno cache deps.ts
RUN deno cache main.ts

CMD ["run", "--allow-read", "--allow-net", "--allow-env", "main.ts"]
