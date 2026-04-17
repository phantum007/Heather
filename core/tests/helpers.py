"""Shared helpers for core unit/API tests (no DB required)."""
from unittest.mock import MagicMock

from rest_framework.test import APIRequestFactory, force_authenticate

_factory = APIRequestFactory()


def make_user(role='student', user_id=1):
    u = MagicMock()
    u.id = user_id
    u.role = role
    u.email = f'{role}@test.com'
    u.name = 'Test User'
    u.password = '$2b$12$fakehash'
    u.is_authenticated = True
    return u


def api_req(method, path, data=None, user=None):
    make = getattr(_factory, method.lower())
    req = make(path, data=data, format='json')
    if user:
        force_authenticate(req, user=user)
    return req
