from unittest.mock import MagicMock, patch

import jwt
from django.conf import settings
from django.test import SimpleTestCase

from core.serializers import LoginSerializer, RegisterSerializer, build_token, serialize_user


def _user(**kwargs):
    u = MagicMock()
    u.id = kwargs.get('id', 1)
    u.name = kwargs.get('name', 'Alice')
    u.email = kwargs.get('email', 'alice@example.com')
    u.role = kwargs.get('role', 'student')
    return u


class SerializerHelpersTest(SimpleTestCase):

    def test_serialize_user_shape(self):
        data = serialize_user(_user())
        self.assertEqual(set(data.keys()), {'id', 'name', 'email', 'role'})

    def test_serialize_user_values(self):
        user = _user(id=7, name='Bob', email='bob@x.com', role='teacher')
        data = serialize_user(user)
        self.assertEqual(data['id'], 7)
        self.assertEqual(data['name'], 'Bob')
        self.assertEqual(data['email'], 'bob@x.com')
        self.assertEqual(data['role'], 'teacher')

    def test_build_token_returns_string(self):
        token = build_token(_user())
        self.assertIsInstance(token, str)
        self.assertGreater(len(token), 10)

    def test_build_token_decodable(self):
        user = _user(id=5)
        token = build_token(user)
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
        self.assertEqual(payload['id'], 5)


class LoginSerializerTest(SimpleTestCase):

    def test_valid_credentials_sets_user(self):
        user = _user()
        with patch('core.serializers.AppUser.objects') as m, \
             patch('core.serializers.bcrypt.checkpw', return_value=True):
            m.get.return_value = user
            s = LoginSerializer(data={'email': 'u@test.com', 'password': 'pw'})
            self.assertTrue(s.is_valid())
            self.assertEqual(s.validated_data['user'], user)

    def test_user_not_found_invalid(self):
        with patch('core.serializers.AppUser.objects') as m:
            from core.models import AppUser
            m.get.side_effect = AppUser.DoesNotExist
            s = LoginSerializer(data={'email': 'no@test.com', 'password': 'pw'})
            self.assertFalse(s.is_valid())

    def test_wrong_password_invalid(self):
        with patch('core.serializers.AppUser.objects') as m, \
             patch('core.serializers.bcrypt.checkpw', return_value=False):
            m.get.return_value = _user()
            s = LoginSerializer(data={'email': 'u@test.com', 'password': 'bad'})
            self.assertFalse(s.is_valid())


class RegisterSerializerTest(SimpleTestCase):

    def test_student_missing_grade_invalid(self):
        s = RegisterSerializer(data={
            'name': 'A', 'email': 'a@b.com', 'password': 'pw', 'role': 'student',
        })
        self.assertFalse(s.is_valid())

    def test_teacher_no_grade_valid(self):
        s = RegisterSerializer(data={
            'name': 'A', 'email': 'a@b.com', 'password': 'pw', 'role': 'teacher',
        })
        self.assertTrue(s.is_valid())

    def test_invalid_role(self):
        s = RegisterSerializer(data={
            'name': 'A', 'email': 'a@b.com', 'password': 'pw', 'role': 'admin',
        })
        self.assertFalse(s.is_valid())
