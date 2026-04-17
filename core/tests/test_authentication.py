from unittest.mock import MagicMock, patch

import jwt
from django.test import SimpleTestCase
from rest_framework import exceptions

from core.authentication import JWTAuthentication


class JWTAuthenticationTest(SimpleTestCase):

    def setUp(self):
        self.auth = JWTAuthentication()

    @patch('core.authentication.get_authorization_header', return_value=b'')
    def test_no_header_returns_none(self, _mock):
        req = MagicMock()
        with patch('core.authentication.get_authorization_header', return_value=b''):
            result = self.auth.authenticate(req)
        self.assertIsNone(result)

    def test_wrong_scheme_raises(self):
        with patch('core.authentication.get_authorization_header', return_value=b'Basic abc123'):
            with self.assertRaises(exceptions.AuthenticationFailed):
                self.auth.authenticate(MagicMock())

    def test_missing_token_raises(self):
        with patch('core.authentication.get_authorization_header', return_value=b'Bearer'):
            with self.assertRaises(exceptions.AuthenticationFailed):
                self.auth.authenticate(MagicMock())

    def test_invalid_jwt_raises(self):
        with patch('core.authentication.get_authorization_header', return_value=b'Bearer badtoken'), \
             patch('core.authentication.jwt.decode') as mock_decode:
            mock_decode.side_effect = jwt.PyJWTError('bad')
            with self.assertRaises(exceptions.AuthenticationFailed):
                self.auth.authenticate(MagicMock())

    def test_payload_missing_id_raises(self):
        with patch('core.authentication.get_authorization_header', return_value=b'Bearer validtoken'), \
             patch('core.authentication.jwt.decode', return_value={'email': 'x@x.com'}):
            with self.assertRaises(exceptions.AuthenticationFailed):
                self.auth.authenticate(MagicMock())

    def test_user_not_found_raises(self):
        with patch('core.authentication.get_authorization_header', return_value=b'Bearer validtoken'), \
             patch('core.authentication.jwt.decode', return_value={'id': 99}), \
             patch('core.authentication.AppUser.objects.get') as mock_get:
            from core.models import AppUser
            mock_get.side_effect = AppUser.DoesNotExist
            with self.assertRaises(exceptions.AuthenticationFailed):
                self.auth.authenticate(MagicMock())

    def test_valid_token_returns_user_and_token(self):
        user = MagicMock()
        with patch('core.authentication.get_authorization_header', return_value=b'Bearer mytoken'), \
             patch('core.authentication.jwt.decode', return_value={'id': 1}), \
             patch('core.authentication.AppUser.objects.get', return_value=user):
            result = self.auth.authenticate(MagicMock())
        self.assertEqual(result, (user, 'mytoken'))
