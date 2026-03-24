# Django REST Backend

This folder contains the Django REST replacement for the old Node/Express backend.

## Stack

- Django
- Django REST Framework
- PostgreSQL
- Custom JWT authentication
- `bcrypt` password hashing compatible with the previous backend

## Run

```bash
cd backend_django
../.venv/bin/python manage.py runserver 127.0.0.1:8000
```

Backend API base URL:

```text
http://127.0.0.1:8000/api
```

Swagger UI:

```text
http://127.0.0.1:8000/api/docs/
```

OpenAPI schema:

```text
http://127.0.0.1:8000/api/schema/
```

## Environment

Local defaults live in `.env`.

Important values:

- `DB_HOST`
- `DB_PORT`
- `DB_USER`
- `DB_PASSWORD`
- `DB_NAME`
- `JWT_SECRET`
- `JWT_EXPIRES_IN`

## Notes

- The Django models map onto the existing PostgreSQL tables used by the old backend.
- The frontend now defaults to `http://127.0.0.1:8000/api`.
- The old Node backend is still present in `backend/` until you decide to remove it.
