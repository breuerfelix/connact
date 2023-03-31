# search

## environment variables

```env
MONGO_URL=
JWT_SECRET=
```

## api spec

all routes require a valid JWT token

- `GET /search?username=foobar` => searches for user by username

