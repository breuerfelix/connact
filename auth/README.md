# auth

## environment variables

```env
MONGO_URL=
JWT_SECRET=
```

## api spec

all routes require a valid JWT token

- `POST /signup` => registers new user
- `POST /login` => logs in user

## TODO

- add expiry date to token
- use refresh token
- delete user
