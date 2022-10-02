# user data

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

- `GET /user` => returns own data
- `GET /user/:username` => returns desired user if you are in the desired users `contacts` field
- `POST /user` => creates your own user
- `PUT /user` => updates your own user
- `DELETE /user` => deletes your own user

## TODO

- put contacts into groups
- have a well defined user spec
