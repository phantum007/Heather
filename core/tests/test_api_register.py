from unittest.mock import MagicMock, patch

from django.test import SimpleTestCase

import core.views as api_views
from core.tests.helpers import api_req, make_user


class RegisterViewTest(SimpleTestCase):

    def test_missing_fields_returns_400(self):
        r = api_views.RegisterView.as_view()(api_req('post', '/api/register/', data={}))
        self.assertEqual(r.status_code, 400)

    def test_student_missing_grade_returns_400(self):
        r = api_views.RegisterView.as_view()(api_req('post', '/api/register/', data={
            'name': 'Alice', 'email': 'a@b.com', 'password': 'pw', 'role': 'student',
        }))
        self.assertEqual(r.status_code, 400)

    @patch('core.serializers.AppUser.objects')
    @patch('core.serializers.StudentProfile.objects')
    @patch('core.serializers.bcrypt.hashpw', return_value=b'hashed')
    @patch('core.serializers.bcrypt.gensalt', return_value=b'salt')
    def test_valid_student_registration_returns_201(self, _salt, _hash, mock_sp, mock_usr):
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        user = make_user(role='student')
        mock_usr.filter.return_value.exists.return_value = False
        mock_usr.create.return_value = user
        with patch('core.serializers.transaction.atomic', return_value=ctx):
            r = api_views.RegisterView.as_view()(api_req('post', '/api/register/', data={
                'name': 'Alice', 'email': 'alice@test.com',
                'password': 'pw', 'role': 'student', 'gradeId': 1,
            }))
        self.assertEqual(r.status_code, 201)
        self.assertIn('token', r.data)
        self.assertIn('user', r.data)

    @patch('core.serializers.AppUser.objects')
    @patch('core.serializers.bcrypt.hashpw', return_value=b'hashed')
    @patch('core.serializers.bcrypt.gensalt', return_value=b'salt')
    def test_valid_teacher_registration_returns_201(self, _salt, _hash, mock_usr):
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        user = make_user(role='teacher')
        mock_usr.filter.return_value.exists.return_value = False
        mock_usr.create.return_value = user
        with patch('core.serializers.transaction.atomic', return_value=ctx):
            r = api_views.RegisterView.as_view()(api_req('post', '/api/register/', data={
                'name': 'Bob', 'email': 'bob@test.com', 'password': 'pw', 'role': 'teacher',
            }))
        self.assertEqual(r.status_code, 201)

    @patch('core.serializers.AppUser.objects')
    @patch('core.serializers.bcrypt.hashpw', return_value=b'hashed')
    @patch('core.serializers.bcrypt.gensalt', return_value=b'salt')
    def test_duplicate_email_returns_400(self, _salt, _hash, mock_usr):
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        mock_usr.filter.return_value.exists.return_value = True
        with patch('core.serializers.transaction.atomic', return_value=ctx):
            r = api_views.RegisterView.as_view()(api_req('post', '/api/register/', data={
                'name': 'X', 'email': 'x@test.com', 'password': 'pw', 'role': 'teacher',
            }))
        self.assertEqual(r.status_code, 400)
