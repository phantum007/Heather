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

- `DATABASE_URL`
- `USE_LOCAL_DB`
- `PGHOST`
- `PGPORT`
- `PGDATABASE`
- `PGUSER`
- `PGPASSWORD`
- `PGSSLMODE`
- `DB_HOST`
- `DB_PORT`
- `DB_USER`
- `DB_PASSWORD`
- `DB_NAME`
- `JWT_SECRET`
- `JWT_EXPIRES_IN`

## Notes

- `DATABASE_URL` is the preferred hosted database setting.
- Railway deployments can also use the standard `PG*` environment variables Railway injects automatically.
- Set `USE_LOCAL_DB=true` to force the app to use the local `DB_*` values instead of `DATABASE_URL`.
- The Django models map onto the existing PostgreSQL tables used by the old backend.
- The frontend now defaults to `http://127.0.0.1:8000/api`.
- The old Node backend is still present in `backend/` until you decide to remove it.

## Cloud Run

Set `DATABASE_URL` on the Cloud Run service so the container uses Neon for both `manage.py migrate` and the app process.

Example:

```bash
gcloud run services update SERVICE_NAME \
  --region=REGION \
  --update-env-vars="DATABASE_URL=postgresql://neondb_owner:npg_BhaM8JbHok5I@ep-broad-dawn-am4h60kv-pooler.c-5.us-east-1.aws.neon.tech/abacus?sslmode=require&channel_binding=require"
```

## Railway

This branch is ready to deploy on Railway using either:

- `DATABASE_URL`
- Railway-managed `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`, and `PGSSLMODE`

If Railway provides `RAILWAY_PUBLIC_DOMAIN`, the default allowed hosts and CSRF trusted origins will include it automatically.
