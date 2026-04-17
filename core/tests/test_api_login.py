from unittest.mock import patch

from django.test import SimpleTestCase

import core.views as api_views
from core.tests.helpers import api_req, make_user


class LoginViewTest(SimpleTestCase):

    def test_invalid_email_returns_401(self):
        with patch('core.serializers.AppUser.objects') as m:
            from core.models import AppUser
            m.get.side_effect = AppUser.DoesNotExist
            r = api_views.LoginView.as_view()(api_req('post', '/api/login/', data={
                'email': 'no@no.com', 'password': 'pw',
            }))
        self.assertEqual(r.status_code, 401)

    def test_wrong_password_returns_401(self):
        with patch('core.serializers.AppUser.objects') as m, \
             patch('core.serializers.bcrypt.checkpw', return_value=False):
            m.get.return_value = make_user()
            r = api_views.LoginView.as_view()(api_req('post', '/api/login/', data={
                'email': 'u@test.com', 'password': 'bad',
            }))
        self.assertEqual(r.status_code, 401)

    def test_valid_credentials_returns_200(self):
        user = make_user()
        with patch('core.serializers.AppUser.objects') as m, \
             patch('core.serializers.bcrypt.checkpw', return_value=True):
            m.get.return_value = user
            r = api_views.LoginView.as_view()(api_req('post', '/api/login/', data={
                'email': 'u@test.com', 'password': 'good',
            }))
        self.assertEqual(r.status_code, 200)
        self.assertIn('token', r.data)
        self.assertIn('user', r.data)
