"""
Regression tests for UI views.

Uses SimpleTestCase + RequestFactory — no database is created.
All model access is mocked; tests focus on HTTP contracts:
status codes, redirect targets, JSON shapes, and guard behaviour.
"""
import json
from unittest.mock import MagicMock, patch

from django.test import RequestFactory, SimpleTestCase

import ui.views as views


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _make_user(role='student', user_id=1):
    user = MagicMock()
    user.id = user_id
    user.role = role
    user.email = f'{role}@test.com'
    user.name = 'Test User'
    user.is_authenticated = True
    return user


def _request(factory, method, path, data=None, session_user_id=None):
    """Build a request and attach a minimal mock session."""
    make = getattr(factory, method.lower())
    req = make(path, data=data or {})
    session = {}
    if session_user_id is not None:
        session[views.SESSION_USER_ID] = session_user_id
    req.session = session
    return req


# ---------------------------------------------------------------------------
# Auth guard tests
# ---------------------------------------------------------------------------

class AuthGuardTest(SimpleTestCase):
    """Unauthenticated requests must redirect to /login/."""

    def setUp(self):
        self.factory = RequestFactory()

    def _get_unauthed(self, view_fn, path='/'):
        req = _request(self.factory, 'get', path)
        return view_fn(req)

    def test_student_assignments_requires_auth(self):
        resp = self._get_unauthed(
            views.student_assignments, '/student/assignments/'
        )
        self.assertEqual(resp.status_code, 302)
        self.assertIn('/login/', resp['Location'])

    def test_student_coins_requires_auth(self):
        resp = self._get_unauthed(
            views.student_coins, '/student/coins/'
        )
        self.assertEqual(resp.status_code, 302)
        self.assertIn('/login/', resp['Location'])

    def test_teacher_dashboard_requires_auth(self):
        resp = self._get_unauthed(
            views.teacher_dashboard, '/teacher/'
        )
        self.assertEqual(resp.status_code, 302)
        self.assertIn('/login/', resp['Location'])

    def test_student_blocked_from_teacher_view(self):
        req = _request(
            self.factory, 'get', '/teacher/', session_user_id=1
        )
        with patch('ui.views._get_current_user') as m:
            m.return_value = _make_user(role='student')
            resp = views.teacher_dashboard(req)
        self.assertEqual(resp.status_code, 403)

    def test_teacher_blocked_from_student_view(self):
        req = _request(
            self.factory, 'get', '/student/assignments/',
            session_user_id=1,
        )
        with patch('ui.views._get_current_user') as m:
            m.return_value = _make_user(role='teacher')
            resp = views.student_assignments(req)
        self.assertEqual(resp.status_code, 403)


# ---------------------------------------------------------------------------
# Login view
# ---------------------------------------------------------------------------

class LoginViewTest(SimpleTestCase):
    """Tests for the login/logout flow."""

    def setUp(self):
        self.factory = RequestFactory()

    def test_login_get_returns_200(self):
        req = _request(self.factory, 'get', '/login/')
        self.assertEqual(views.login_view(req).status_code, 200)

    @patch('ui.views.AppUser.objects')
    @patch('ui.views.bcrypt.checkpw', return_value=False)
    def test_bad_credentials_rerenders_login(self, _chk, mock_mgr):
        mock_mgr.get.return_value = _make_user()
        req = _request(
            self.factory, 'post', '/login/',
            data={'email': 'x@x.com', 'password': 'wrong'},
        )
        req._messages = MagicMock()
        self.assertEqual(views.login_view(req).status_code, 200)

    @patch('ui.views.AppUser.objects')
    @patch('ui.views.bcrypt.checkpw', return_value=True)
    def test_student_login_redirects_to_assignments(self, _chk, mock_mgr):
        mock_mgr.get.return_value = _make_user(role='student')
        req = _request(
            self.factory, 'post', '/login/',
            data={'email': 'student@test.com', 'password': 'pass'},
        )
        req.session = {}
        resp = views.login_view(req)
        self.assertEqual(resp.status_code, 302)
        self.assertIn('/student/assignments/', resp['Location'])

    @patch('ui.views.AppUser.objects')
    @patch('ui.views.bcrypt.checkpw', return_value=True)
    def test_teacher_login_redirects_to_dashboard(self, _chk, mock_mgr):
        mock_mgr.get.return_value = _make_user(role='teacher')
        req = _request(
            self.factory, 'post', '/login/',
            data={'email': 'teacher@test.com', 'password': 'pass'},
        )
        req.session = {}
        resp = views.login_view(req)
        self.assertEqual(resp.status_code, 302)
        self.assertIn('/teacher/', resp['Location'])

    def test_logout_redirects_to_login(self):
        req = _request(self.factory, 'get', '/logout/')
        req.session = MagicMock()
        resp = views.logout_view(req)
        self.assertEqual(resp.status_code, 302)
        self.assertIn('/login/', resp['Location'])


# ---------------------------------------------------------------------------
# student_submit_unit_question — input validation (before any DB access)
# ---------------------------------------------------------------------------

class UnitSubmitValidationTest(SimpleTestCase):
    """
    /student/unit-practice/submit/ must reject bad input with 400
    before touching the database.
    """

    def setUp(self):
        self.factory = RequestFactory()

    def _post(self, data):
        req = _request(
            self.factory, 'post',
            '/student/unit-practice/submit/', data=data,
        )
        with patch('ui.views._get_current_user') as m:
            m.return_value = _make_user()
            return views.student_submit_unit_question(req)

    def test_missing_unit_id_returns_400(self):
        resp = self._post({
            'question_id': '1',
            'assignment_id': '1',
            'student_answer': '42',
        })
        self.assertEqual(resp.status_code, 400)
        self.assertIn('required', json.loads(resp.content)['message'])

    def test_missing_question_id_returns_400(self):
        resp = self._post({
            'unit_id': '1',
            'assignment_id': '1',
            'student_answer': '42',
        })
        self.assertEqual(resp.status_code, 400)

    def test_missing_assignment_id_returns_400(self):
        resp = self._post({
            'unit_id': '1',
            'question_id': '1',
            'student_answer': '42',
        })
        self.assertEqual(resp.status_code, 400)

    def test_invalid_elapsed_seconds_returns_400(self):
        resp = self._post({
            'unit_id': '1', 'question_id': '1',
            'assignment_id': '1', 'student_answer': '42',
            'elapsed_seconds': 'abc',
        })
        self.assertEqual(resp.status_code, 400)
        body = json.loads(resp.content)
        self.assertIn('elapsed_seconds', body['message'])

    @patch('ui.views.get_object_or_404')
    @patch('ui.views.truncate_numeric_precision', return_value='')
    def test_empty_student_answer_returns_400(self, _trunc, mock_404):
        assignment = MagicMock()
        assignment.lesson_id = 10
        unit = MagicMock()
        unit.sub_lesson.lesson_type_id = 10
        mock_404.side_effect = [assignment, unit, MagicMock()]

        resp = self._post({
            'unit_id': '1', 'question_id': '1',
            'assignment_id': '1', 'student_answer': '',
        })
        self.assertEqual(resp.status_code, 400)
        self.assertIn('student_answer', json.loads(resp.content)['message'])

    @patch('ui.views.get_object_or_404')
    def test_unit_not_in_assignment_returns_400(self, mock_404):
        assignment = MagicMock()
        assignment.lesson_id = 10
        unit = MagicMock()
        unit.sub_lesson.lesson_type_id = 99  # different lesson
        mock_404.side_effect = [assignment, unit, MagicMock()]

        resp = self._post({
            'unit_id': '1', 'question_id': '1',
            'assignment_id': '1', 'student_answer': '42',
        })
        self.assertEqual(resp.status_code, 400)
        body = json.loads(resp.content)
        self.assertIn('does not belong', body['message'])

    def test_get_method_not_allowed(self):
        req = _request(
            self.factory, 'get', '/student/unit-practice/submit/'
        )
        with patch('ui.views._get_current_user') as m:
            m.return_value = _make_user()
            resp = views.student_submit_unit_question(req)
        self.assertEqual(resp.status_code, 405)


# ---------------------------------------------------------------------------
# student_submit_unit_question — JSON response shape
# ---------------------------------------------------------------------------

class UnitSubmitResponseShapeTest(SimpleTestCase):
    """Submit endpoint returns expected JSON keys for correct/incorrect."""

    def setUp(self):
        self.factory = RequestFactory()

    def _submit(self, student_answer, correct_answer):
        user = _make_user()

        assignment = MagicMock()
        assignment.id = 1
        assignment.lesson_id = 10

        unit = MagicMock()
        unit.id = 1
        unit.sub_lesson.lesson_type_id = 10
        unit.curriculum_questions.count.return_value = 5

        question = MagicMock()
        question.id = 1
        question.answer_text = correct_answer

        attempt = MagicMock()
        attempt.id = 99
        attempt.attempt_number = 1
        attempt.elapsed_seconds = 0
        attempt.status = 'in_progress'
        attempt.correct_count = 0
        attempt.wrong_count = 0
        is_right = (student_answer == correct_answer)
        attempt.question_attempts.all.return_value = [
            MagicMock(is_correct=is_right)
        ]

        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)

        req = _request(
            self.factory, 'post',
            '/student/unit-practice/submit/',
            data={
                'unit_id': '1', 'question_id': '1',
                'assignment_id': '1',
                'student_answer': student_answer,
                'elapsed_seconds': '5',
            },
        )

        with \
            patch('ui.views._get_current_user', return_value=user), \
            patch(
                'ui.views.get_object_or_404',
                side_effect=[assignment, unit, question],
            ), \
            patch(
                'ui.views.CurriculumUnitAttempt.objects'
            ) as mock_att, \
            patch('ui.views.CurriculumQuestionAttempt.objects') as mock_qa, \
            patch('ui.views.StudentProfile.objects'), \
            patch('ui.views.transaction.atomic', return_value=ctx):

            mock_att.filter.return_value \
                .order_by.return_value.first.return_value = None
            mock_att.create.return_value = attempt
            mock_qa.get_or_create.return_value = (MagicMock(), True)

            return views.student_submit_unit_question(req)

    def test_status_200(self):
        self.assertEqual(self._submit('42', '42').status_code, 200)

    def test_response_contains_required_keys(self):
        data = json.loads(self._submit('42', '42').content)
        for key in (
            'is_correct', 'status', 'correct_count', 'wrong_count',
            'is_complete', 'attempt_status', 'attempt_number',
            'coins_awarded',
        ):
            self.assertIn(key, data, msg=f'Missing key: {key}')

    def test_correct_answer_fields(self):
        data = json.loads(self._submit('42', '42').content)
        self.assertEqual(data['status'], 'correct')
        self.assertTrue(data['is_correct'])

    def test_incorrect_answer_fields(self):
        data = json.loads(self._submit('99', '42').content)
        self.assertEqual(data['status'], 'incorrect')
        self.assertFalse(data['is_correct'])


# ---------------------------------------------------------------------------
# Assignment model constants
# ---------------------------------------------------------------------------

class AssignmentModelConstantsTest(SimpleTestCase):
    """Assignment mode/kind constants must exist with expected values."""

    def test_mode_sprint(self):
        from core.models import Assignment
        self.assertEqual(Assignment.MODE_SPRINT, 'sprint')

    def test_mode_standard(self):
        from core.models import Assignment
        self.assertEqual(Assignment.MODE_STANDARD, 'standard')

    def test_mode_lock(self):
        from core.models import Assignment
        self.assertEqual(Assignment.MODE_LOCK, 'lock')

    def test_mode_choices_contains_all_modes(self):
        from core.models import Assignment
        values = [m[0] for m in Assignment.MODE_CHOICES]
        for mode in ('sprint', 'standard', 'lock'):
            self.assertIn(mode, values)

    def test_kind_homework(self):
        from core.models import Assignment
        self.assertEqual(Assignment.KIND_HOMEWORK, 'homework')

    def test_kind_classroom(self):
        from core.models import Assignment
        self.assertEqual(Assignment.KIND_CLASSROOM, 'classroom')


# ---------------------------------------------------------------------------
# Assignment mode validation (replicates guard in teacher_create_assignment)
# ---------------------------------------------------------------------------

class AssignmentModeValidationTest(SimpleTestCase):
    """Invalid assignment_mode values must fall back to 'sprint'."""

    def _validated(self, raw):
        from core.models import Assignment
        mode = (raw or '').strip()
        if mode not in {
            Assignment.MODE_SPRINT,
            Assignment.MODE_STANDARD,
            Assignment.MODE_LOCK,
        }:
            mode = Assignment.MODE_SPRINT
        return mode

    def test_sprint_passes(self):
        self.assertEqual(self._validated('sprint'), 'sprint')

    def test_standard_passes(self):
        self.assertEqual(self._validated('standard'), 'standard')

    def test_lock_passes(self):
        self.assertEqual(self._validated('lock'), 'lock')

    def test_empty_string_falls_back_to_sprint(self):
        self.assertEqual(self._validated(''), 'sprint')

    def test_unknown_value_falls_back_to_sprint(self):
        self.assertEqual(self._validated('unknown'), 'sprint')

    def test_uppercase_falls_back_to_sprint(self):
        self.assertEqual(self._validated('SPRINT'), 'sprint')

    def test_none_falls_back_to_sprint(self):
        self.assertEqual(self._validated(None), 'sprint')
