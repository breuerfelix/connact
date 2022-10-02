FROM denoland/deno:alpine

EXPOSE 80
WORKDIR /app
USER deno

COPY deps.ts .
RUN deno cache deps.ts

ADD . .
RUN deno cache main.ts

CMD ["run", "--allow-read", "--allow-net", "--allow-env", "main.ts"]
