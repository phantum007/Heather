import os
from datetime import timedelta
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

ENV_PATH = BASE_DIR / '.env'
if ENV_PATH.exists():
    for raw_line in ENV_PATH.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith('#') or '=' not in line:
            continue
        key, value = line.split('=', 1)
        os.environ.setdefault(key.strip(), value.strip())


def _parse_jwt_expiry(raw_value: str) -> timedelta:
    value = (raw_value or '1d').strip().lower()
    suffix = value[-1]
    amount = value[:-1] if suffix.isalpha() else value
    amount = int(amount or '1')
    if suffix == 'd':
        return timedelta(days=amount)
    if suffix == 'h':
        return timedelta(hours=amount)
    if suffix == 'm':
        return timedelta(minutes=amount)
    if suffix == 's':
        return timedelta(seconds=amount)
    return timedelta(seconds=int(value))


def _env_flag(name: str, default: bool = False) -> bool:
    return os.getenv(name, str(default)).lower() == 'true'


def _csv_env(name: str, default_values: list[str]) -> list[str]:
    raw_value = os.getenv(name, ','.join(default_values))
    return [item.strip() for item in raw_value.split(',') if item.strip()]


def _database_settings() -> dict:
    use_local_db = _env_flag('USE_LOCAL_DB')

    name = os.getenv('PGDATABASE') or os.getenv('DB_NAME', 'abacus_platform')
    user = os.getenv('PGUSER') or os.getenv('DB_USER', 'postgres')
    password = os.getenv('PGPASSWORD') or os.getenv('DB_PASSWORD', '')
    host = os.getenv('RAILWAY_SERVICE_POSTGRES_URL') or os.getenv('PGHOST') or os.getenv('DB_HOST', 'localhost')
    port = os.getenv('PGPORT') or os.getenv('DB_PORT', '5432')
    options = {}

    if use_local_db:
        name = os.getenv('DB_NAME', 'abacus_platform')
        user = os.getenv('DB_USER', 'postgres')
        password = os.getenv('DB_PASSWORD', '')
        host = os.getenv('DB_HOST', 'localhost')
        port = os.getenv('DB_PORT', '5432')

    if host != 'localhost':
        options['sslmode'] = os.getenv('PGSSLMODE', 'require')

    return {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': name,
        'USER': user,
        'PASSWORD': password,
        'HOST': host,
        'PORT': port,
        'OPTIONS': options,
    }


SECRET_KEY = os.getenv('JWT_SECRET', 'super_secret_change_me')
DEBUG = _env_flag('DEBUG')

default_csrf_trusted_origins = ['https://*.up.railway.app', 'https://*.run.app']
if os.getenv('RAILWAY_PUBLIC_DOMAIN'):
    default_csrf_trusted_origins.append(f"https://{os.getenv('RAILWAY_PUBLIC_DOMAIN')}")
if os.getenv('APP_DOMAIN'):
    default_csrf_trusted_origins.append(f"https://{os.getenv('APP_DOMAIN')}")
if os.getenv('APP_URL', '').startswith('https://'):
    default_csrf_trusted_origins.append(os.getenv('APP_URL'))

CSRF_TRUSTED_ORIGINS = _csv_env('CSRF_TRUSTED_ORIGINS', default_csrf_trusted_origins)

default_allowed_hosts = ['*.up.railway.app', '*.run.app', 'localhost', '127.0.0.1']
if os.getenv('RAILWAY_PUBLIC_DOMAIN'):
    default_allowed_hosts.append(os.getenv('RAILWAY_PUBLIC_DOMAIN'))
if os.getenv('APP_DOMAIN'):
    default_allowed_hosts.append(os.getenv('APP_DOMAIN'))

ALLOWED_HOSTS = _csv_env('ALLOWED_HOSTS', default_allowed_hosts) or ['*']

SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
USE_X_FORWARDED_HOST = True
CSRF_COOKIE_SECURE = not DEBUG
SESSION_COOKIE_SECURE = not DEBUG

INSTALLED_APPS = [
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'corsheaders',
    'rest_framework',
    'drf_spectacular',
    'api',
    'ui',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

# DATABASES = {'default': _database_settings()}

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('PGDATABASE'),
        'USER': os.environ.get('PGUSER'),
        'PASSWORD': os.environ.get('PGPASSWORD'),
        'HOST': os.environ.get('PGHOST'),
        'PORT': os.environ.get('PGPORT'),
        'OPTIONS': {
            'sslmode': 'require',
        },
    }}

LANGUAGE_CODE = 'en-us'
TIME_ZONE = os.getenv('TIME_ZONE', 'Europe/London')
USE_I18N = True
USE_TZ = True

STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

MEDIA_URL = '/media/'
MEDIA_ROOT = str(BASE_DIR / 'media')
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
CORS_ALLOW_ALL_ORIGINS = True

JWT_ALGORITHM = 'HS256'
JWT_EXPIRY = _parse_jwt_expiry(os.getenv('JWT_EXPIRES_IN', '1d'))

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'api.authentication.JWTAuthentication',
    ],
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
    'UNAUTHENTICATED_USER': None,
}

SPECTACULAR_SETTINGS = {
    'TITLE': 'Abacus Platform API',
    'DESCRIPTION': 'Django REST API for the Abacus practice management platform.',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
    'SCHEMA_PATH_PREFIX': r'/api',
}
