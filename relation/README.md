# relation service

## environment variables

```env
DB_URL=
DB_USER=
DB_PASS=
DB_NAMESPACE=
DB_DATABASE=
JWT_SECRET=
```

## api spec

all routes require a valid JWT token

- `POST /relation/:username` => requests or approve user `username` to be contacts
- `DELETE /relation/:username` => deletes relation with the user `username`

## TODO

