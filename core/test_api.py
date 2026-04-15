"""
Regression tests for DRF API views (core/views.py) and serializers.
Uses SimpleTestCase + APIRequestFactory — no database is created.
"""
from unittest.mock import MagicMock, patch

from django.test import SimpleTestCase
from rest_framework.test import APIRequestFactory, force_authenticate

import core.views as api_views
from core.serializers import LoginSerializer, RegisterSerializer


# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

_factory = APIRequestFactory()


def _make_user(role='student', user_id=1):
    u = MagicMock()
    u.id = user_id
    u.role = role
    u.email = f'{role}@test.com'
    u.name = 'Test User'
    u.password = '$2b$12$fakehash'
    u.is_authenticated = True
    return u


def _api_req(method, path, data=None, user=None):
    make = getattr(_factory, method.lower())
    req = make(path, data=data, format='json')
    if user:
        force_authenticate(req, user=user)
    return req


# ---------------------------------------------------------------------------
# HealthView
# ---------------------------------------------------------------------------

class HealthViewTest(SimpleTestCase):

    def test_get_returns_ok(self):
        req = _api_req('get', '/api/health/')
        r = api_views.HealthView.as_view()(req)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.data['status'], 'ok')

    def test_get_contains_service_name(self):
        req = _api_req('get', '/api/health/')
        r = api_views.HealthView.as_view()(req)
        self.assertIn('service', r.data)


# ---------------------------------------------------------------------------
# RegisterView
# ---------------------------------------------------------------------------

class RegisterViewTest(SimpleTestCase):

    def test_missing_fields_returns_400(self):
        req = _api_req('post', '/api/register/', data={})
        r = api_views.RegisterView.as_view()(req)
        self.assertEqual(r.status_code, 400)

    def test_student_missing_grade_returns_400(self):
        req = _api_req('post', '/api/register/', data={
            'name': 'Alice', 'email': 'a@b.com',
            'password': 'pw', 'role': 'student',
        })
        r = api_views.RegisterView.as_view()(req)
        self.assertEqual(r.status_code, 400)

    @patch('core.serializers.AppUser.objects')
    @patch('core.serializers.StudentProfile.objects')
    @patch('core.serializers.bcrypt.hashpw', return_value=b'hashed')
    @patch('core.serializers.bcrypt.gensalt', return_value=b'salt')
    def test_valid_student_registration_returns_201(
        self, _salt, _hash, mock_sp, mock_usr
    ):
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        user = _make_user(role='student')
        mock_usr.filter.return_value.exists.return_value = False
        mock_usr.create.return_value = user

        with patch('core.serializers.transaction.atomic', return_value=ctx):
            req = _api_req('post', '/api/register/', data={
                'name': 'Alice', 'email': 'alice@test.com',
                'password': 'pw', 'role': 'student', 'gradeId': 1,
            })
            r = api_views.RegisterView.as_view()(req)
        self.assertEqual(r.status_code, 201)
        self.assertIn('token', r.data)
        self.assertIn('user', r.data)

    @patch('core.serializers.AppUser.objects')
    @patch('core.serializers.bcrypt.hashpw', return_value=b'hashed')
    @patch('core.serializers.bcrypt.gensalt', return_value=b'salt')
    def test_valid_teacher_registration_returns_201(
        self, _salt, _hash, mock_usr
    ):
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        user = _make_user(role='teacher')
        mock_usr.filter.return_value.exists.return_value = False
        mock_usr.create.return_value = user

        with patch('core.serializers.transaction.atomic', return_value=ctx):
            req = _api_req('post', '/api/register/', data={
                'name': 'Bob', 'email': 'bob@test.com',
                'password': 'pw', 'role': 'teacher',
            })
            r = api_views.RegisterView.as_view()(req)
        self.assertEqual(r.status_code, 201)

    @patch('core.serializers.AppUser.objects')
    @patch('core.serializers.bcrypt.hashpw', return_value=b'hashed')
    @patch('core.serializers.bcrypt.gensalt', return_value=b'salt')
    def test_duplicate_email_returns_400(self, _salt, _hash, mock_usr):
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        # filter().exists() returns True → duplicate
        mock_usr.filter.return_value.exists.return_value = True

        with patch('core.serializers.transaction.atomic', return_value=ctx):
            req = _api_req('post', '/api/register/', data={
                'name': 'X', 'email': 'x@test.com',
                'password': 'pw', 'role': 'teacher',
            })
            r = api_views.RegisterView.as_view()(req)
        self.assertEqual(r.status_code, 400)


# ---------------------------------------------------------------------------
# LoginView
# ---------------------------------------------------------------------------

class LoginViewTest(SimpleTestCase):

    def test_invalid_email_returns_401(self):
        with patch('core.serializers.AppUser.objects') as m:
            from core.models import AppUser
            m.get.side_effect = AppUser.DoesNotExist
            req = _api_req('post', '/api/login/', data={
                'email': 'no@no.com', 'password': 'pw',
            })
            r = api_views.LoginView.as_view()(req)
        self.assertEqual(r.status_code, 401)

    def test_wrong_password_returns_401(self):
        with patch('core.serializers.AppUser.objects') as m, \
             patch('core.serializers.bcrypt.checkpw', return_value=False):
            m.get.return_value = _make_user()
            req = _api_req('post', '/api/login/', data={
                'email': 'u@test.com', 'password': 'bad',
            })
            r = api_views.LoginView.as_view()(req)
        self.assertEqual(r.status_code, 401)

    def test_valid_credentials_returns_200(self):
        user = _make_user()
        with patch('core.serializers.AppUser.objects') as m, \
             patch('core.serializers.bcrypt.checkpw', return_value=True):
            m.get.return_value = user
            req = _api_req('post', '/api/login/', data={
                'email': 'u@test.com', 'password': 'good',
            })
            r = api_views.LoginView.as_view()(req)
        self.assertEqual(r.status_code, 200)
        self.assertIn('token', r.data)
        self.assertIn('user', r.data)


# ---------------------------------------------------------------------------
# TeacherProfileView
# ---------------------------------------------------------------------------

class TeacherProfileViewTest(SimpleTestCase):

    def test_get_returns_user(self):
        user = _make_user(role='teacher')
        req = _api_req('get', '/api/teacher/profile/', user=user)
        # Bypass permission check
        with patch(
            'core.views.IsTeacher.has_permission', return_value=True
        ), patch(
            'core.views.IsAuthenticatedUser.has_permission',
            return_value=True,
        ):
            r = api_views.TeacherProfileView.as_view()(req)
        self.assertEqual(r.status_code, 200)
        self.assertIn('user', r.data)

    def test_patch_invalid_returns_400(self):
        user = _make_user(role='teacher')
        req = _api_req(
            'patch', '/api/teacher/profile/',
            data={},  # missing required name/email → validation fails
            user=user,
        )
        # Patch the serializer's DB check so validation fails on field errors
        with patch(
            'core.serializers.AppUser.objects'
        ) as mock_mgr:
            mock_mgr.exclude.return_value.filter.return_value \
                .exists.return_value = False
            r = api_views.TeacherProfileView.as_view()(req)
        self.assertEqual(r.status_code, 400)


# ---------------------------------------------------------------------------
# StudentsView
# ---------------------------------------------------------------------------

class StudentsViewTest(SimpleTestCase):

    def test_get_returns_list(self):
        user = _make_user(role='teacher')
        req = _api_req('get', '/api/students/', user=user)
        profile = MagicMock()
        profile.user.id = 2
        profile.user.name = 'Student'
        profile.user.email = 's@test.com'
        profile.grade_id = 1
        profile.grade = MagicMock()
        profile.grade.grade_name = 'Grade 1'
        with patch(
            'core.views.IsTeacher.has_permission', return_value=True
        ), patch(
            'core.views.IsAuthenticatedUser.has_permission',
            return_value=True,
        ), patch(
            'core.views.StudentProfile.objects'
        ) as mp:
            mp.select_related.return_value \
                .order_by.return_value = [profile]
            r = api_views.StudentsView.as_view()(req)
        self.assertEqual(r.status_code, 200)
        self.assertIsInstance(r.data, list)


# ---------------------------------------------------------------------------
# GradesLessonsView
# ---------------------------------------------------------------------------

class GradesLessonsViewTest(SimpleTestCase):

    def test_get_returns_list(self):
        user = _make_user(role='teacher')
        req = _api_req('get', '/api/grades-lessons/', user=user)
        grade = MagicMock()
        grade.id = 1
        grade.grade_name = 'Grade 1'
        grade.lesson_types.all.return_value \
            .order_by.return_value = []
        with patch(
            'core.views.IsTeacher.has_permission', return_value=True
        ), patch(
            'core.views.IsAuthenticatedUser.has_permission',
            return_value=True,
        ), patch('core.views.Grade.objects') as mg:
            mg.prefetch_related.return_value.order_by.return_value = [
                grade
            ]
            r = api_views.GradesLessonsView.as_view()(req)
        self.assertEqual(r.status_code, 200)
        self.assertIsInstance(r.data, list)


# ---------------------------------------------------------------------------
# CreateAssignmentView
# ---------------------------------------------------------------------------

class CreateAssignmentViewTest(SimpleTestCase):

    def test_missing_fields_returns_400(self):
        user = _make_user(role='teacher')
        req = _api_req(
            'post', '/api/create-assignment/', data={}, user=user
        )
        with patch(
            'core.views.IsTeacher.has_permission', return_value=True
        ), patch(
            'core.views.IsAuthenticatedUser.has_permission',
            return_value=True,
        ):
            r = api_views.CreateAssignmentView.as_view()(req)
        self.assertEqual(r.status_code, 400)

    def test_question_missing_answer_returns_400(self):
        user = _make_user(role='teacher')
        req = _api_req('post', '/api/create-assignment/', data={
            'studentId': 1, 'lessonId': 1,
            'questions': [{'questionText': 'Q1', 'correctAnswer': ''}],
        }, user=user)
        with patch(
            'core.views.IsTeacher.has_permission', return_value=True
        ), patch(
            'core.views.IsAuthenticatedUser.has_permission',
            return_value=True,
        ):
            r = api_views.CreateAssignmentView.as_view()(req)
        self.assertEqual(r.status_code, 400)

    def test_lesson_not_found_returns_404(self):
        user = _make_user(role='teacher')
        req = _api_req('post', '/api/create-assignment/', data={
            'studentId': 1, 'lessonId': 999,
            'questions': [
                {'questionText': 'Q1', 'correctAnswer': '42'}
            ],
        }, user=user)
        with patch(
            'core.views.IsTeacher.has_permission', return_value=True
        ), patch(
            'core.views.IsAuthenticatedUser.has_permission',
            return_value=True,
        ), patch('core.views.LessonType.objects') as ml:
            from core.models import LessonType
            ml.select_related.return_value.get.side_effect = (
                LessonType.DoesNotExist
            )
            r = api_views.CreateAssignmentView.as_view()(req)
        self.assertEqual(r.status_code, 404)


# ---------------------------------------------------------------------------
# SubmitAnswersView
# ---------------------------------------------------------------------------

class SubmitAnswersViewTest(SimpleTestCase):

    def test_missing_answers_returns_400(self):
        user = _make_user(role='student')
        req = _api_req(
            'post', '/api/submit-answers/', data={}, user=user
        )
        with patch(
            'core.views.IsStudent.has_permission', return_value=True
        ), patch(
            'core.views.IsAuthenticatedUser.has_permission',
            return_value=True,
        ):
            r = api_views.SubmitAnswersView.as_view()(req)
        self.assertEqual(r.status_code, 400)

    def test_answer_missing_question_id_returns_400(self):
        user = _make_user(role='student')
        req = _api_req('post', '/api/submit-answers/', data={
            'answers': [{'studentAnswer': '5'}],  # no questionId
        }, user=user)
        with patch(
            'core.views.IsStudent.has_permission', return_value=True
        ), patch(
            'core.views.IsAuthenticatedUser.has_permission',
            return_value=True,
        ):
            r = api_views.SubmitAnswersView.as_view()(req)
        self.assertEqual(r.status_code, 400)

    def test_question_not_found_returns_400(self):
        user = _make_user(role='student')
        req = _api_req('post', '/api/submit-answers/', data={
            'answers': [{'questionId': 999, 'studentAnswer': '5'}],
        }, user=user)
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        with patch(
            'core.views.IsStudent.has_permission', return_value=True
        ), patch(
            'core.views.IsAuthenticatedUser.has_permission',
            return_value=True,
        ), patch('core.views.Question.objects') as mq, \
             patch('core.views.transaction.atomic', return_value=ctx):
            from core.models import Question
            mq.get.side_effect = Question.DoesNotExist
            r = api_views.SubmitAnswersView.as_view()(req)
        self.assertEqual(r.status_code, 400)

    def test_valid_answers_returns_200(self):
        user = _make_user(role='student')
        user.id = 1
        req = _api_req('post', '/api/submit-answers/', data={
            'answers': [
                {'questionId': 1, 'studentAnswer': '42'},
            ],
        }, user=user)
        question = MagicMock()
        question.id = 1
        question.correct_answer = '42'
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        with patch(
            'core.views.IsStudent.has_permission', return_value=True
        ), patch(
            'core.views.IsAuthenticatedUser.has_permission',
            return_value=True,
        ), patch(
            'core.views.Question.objects'
        ) as mq, patch(
            'core.views.StudentAnswer.objects'
        ), patch(
            'core.views.transaction.atomic', return_value=ctx
        ):
            mq.get.return_value = question
            r = api_views.SubmitAnswersView.as_view()(req)
        self.assertEqual(r.status_code, 200)
        self.assertIn('correct', r.data)
        self.assertIn('total', r.data)
        self.assertIn('percentage', r.data)


# ---------------------------------------------------------------------------
# MyAssignmentsView
# ---------------------------------------------------------------------------

class MyAssignmentsViewTest(SimpleTestCase):

    def test_get_returns_list(self):
        user = _make_user(role='student')
        req = _api_req('get', '/api/my-assignments/', user=user)
        with patch(
            'core.views.IsStudent.has_permission', return_value=True
        ), patch(
            'core.views.IsAuthenticatedUser.has_permission',
            return_value=True,
        ), patch('core.views.Assignment.objects') as ma, \
             patch('core.views.StudentAnswer.objects'):
            ma.filter.return_value \
                .select_related.return_value \
                .prefetch_related.return_value \
                .annotate.return_value \
                .order_by.return_value = []
            r = api_views.MyAssignmentsView.as_view()(req)
        self.assertEqual(r.status_code, 200)
        self.assertIsInstance(r.data, list)


# ---------------------------------------------------------------------------
# LoginSerializer
# ---------------------------------------------------------------------------

class LoginSerializerTest(SimpleTestCase):

    def test_valid_credentials_sets_user(self):
        user = _make_user()
        with patch('core.serializers.AppUser.objects') as m, \
             patch('core.serializers.bcrypt.checkpw', return_value=True):
            m.get.return_value = user
            s = LoginSerializer(data={
                'email': 'u@test.com', 'password': 'pw',
            })
            self.assertTrue(s.is_valid())
            self.assertEqual(s.validated_data['user'], user)

    def test_user_not_found_invalid(self):
        with patch('core.serializers.AppUser.objects') as m:
            from core.models import AppUser
            m.get.side_effect = AppUser.DoesNotExist
            s = LoginSerializer(data={
                'email': 'no@test.com', 'password': 'pw',
            })
            self.assertFalse(s.is_valid())

    def test_wrong_password_invalid(self):
        with patch('core.serializers.AppUser.objects') as m, \
             patch('core.serializers.bcrypt.checkpw', return_value=False):
            m.get.return_value = _make_user()
            s = LoginSerializer(data={
                'email': 'u@test.com', 'password': 'bad',
            })
            self.assertFalse(s.is_valid())


# ---------------------------------------------------------------------------
# RegisterSerializer
# ---------------------------------------------------------------------------

class RegisterSerializerTest(SimpleTestCase):

    def test_student_missing_grade_invalid(self):
        s = RegisterSerializer(data={
            'name': 'A', 'email': 'a@b.com',
            'password': 'pw', 'role': 'student',
        })
        self.assertFalse(s.is_valid())

    def test_teacher_no_grade_valid(self):
        # teacher doesn't need gradeId at validate stage
        s = RegisterSerializer(data={
            'name': 'A', 'email': 'a@b.com',
            'password': 'pw', 'role': 'teacher',
        })
        # validate() passes; save() is mocked separately
        self.assertTrue(s.is_valid())

    def test_invalid_role(self):
        s = RegisterSerializer(data={
            'name': 'A', 'email': 'a@b.com',
            'password': 'pw', 'role': 'admin',
        })
        self.assertFalse(s.is_valid())
