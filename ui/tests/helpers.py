"""Shared helpers for UI unit tests (no DB required)."""
from unittest.mock import MagicMock, patch

from django.http import HttpResponse

SESSION_USER_ID = 'ui_user_id'


def make_user(role='student', user_id=1):
    u = MagicMock()
    u.id = user_id
    u.role = role
    u.email = f'{role}@test.com'
    u.name = 'Test User'
    u.is_authenticated = True
    return u


def make_req(factory, method, path, data=None, session_user_id=None):
    make = getattr(factory, method.lower())
    r = make(path, data=data or {})
    r.session = ({SESSION_USER_ID: session_user_id} if session_user_id else {})
    return r


def mock_render():
    return patch('ui.views.render', return_value=HttpResponse())


def mock_messages():
    return (
        patch('ui.views.messages.error'),
        patch('ui.views.messages.success'),
    )
