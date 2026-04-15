"""
Regression tests for UI views.

Uses SimpleTestCase + RequestFactory — no database is created.
All model/template access is mocked where needed.
"""
import json
from http import HTTPStatus
from unittest.mock import MagicMock, patch

from django.http import HttpResponse
from django.test import RequestFactory, SimpleTestCase

import ui.views as views


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _make_user(role='student', user_id=1):
    u = MagicMock()
    u.id = user_id
    u.role = role
    u.email = f'{role}@test.com'
    u.name = 'Test User'
    u.is_authenticated = True
    return u


def _req(factory, method, path, data=None, session_user_id=None):
    make = getattr(factory, method.lower())
    r = make(path, data=data or {})
    r.session = (
        {views.SESSION_USER_ID: session_user_id}
        if session_user_id else {}
    )
    return r


def _mock_render():
    """Patch ui.views.render to return a plain 200 response."""
    return patch('ui.views.render', return_value=HttpResponse())


def _mock_messages():
    """Patch both messages.error and messages.success in ui.views."""
    return (
        patch('ui.views.messages.error'),
        patch('ui.views.messages.success'),
    )


# ---------------------------------------------------------------------------
# Auth guard tests
# ---------------------------------------------------------------------------

class AuthGuardTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def _unauthed(self, fn, path='/'):
        return fn(_req(self.f, 'get', path))

    def test_student_assignments_requires_auth(self):
        r = self._unauthed(
            views.student_assignments, '/student/assignments/'
        )
        self.assertEqual(r.status_code, 302)
        self.assertIn('/login/', r['Location'])

    def test_student_coins_requires_auth(self):
        r = self._unauthed(views.student_coins, '/student/coins/')
        self.assertEqual(r.status_code, 302)

    def test_teacher_dashboard_requires_auth(self):
        r = self._unauthed(views.teacher_dashboard, '/teacher/')
        self.assertEqual(r.status_code, 302)

    def test_student_blocked_from_teacher_view(self):
        req = _req(self.f, 'get', '/teacher/', session_user_id=1)
        with patch('ui.views._get_current_user') as m:
            m.return_value = _make_user(role='student')
            r = views.teacher_dashboard(req)
        self.assertEqual(r.status_code, 403)

    def test_teacher_blocked_from_student_view(self):
        req = _req(
            self.f, 'get', '/student/assignments/', session_user_id=1
        )
        with patch('ui.views._get_current_user') as m:
            m.return_value = _make_user(role='teacher')
            r = views.student_assignments(req)
        self.assertEqual(r.status_code, 403)


# ---------------------------------------------------------------------------
# home view
# ---------------------------------------------------------------------------

class HomeViewTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_no_user_redirects_to_login(self):
        req = _req(self.f, 'get', '/')
        r = views.home(req)
        self.assertIn('/login/', r['Location'])

    def test_teacher_redirects_to_dashboard(self):
        req = _req(self.f, 'get', '/')
        with patch('ui.views._get_current_user') as m:
            m.return_value = _make_user(role='teacher')
            r = views.home(req)
        self.assertIn('/teacher/', r['Location'])

    def test_student_redirects_to_assignments(self):
        req = _req(self.f, 'get', '/')
        with patch('ui.views._get_current_user') as m:
            m.return_value = _make_user(role='student')
            r = views.home(req)
        self.assertIn('/student/assignments/', r['Location'])

    def test_unknown_role_redirects_to_login(self):
        req = _req(self.f, 'get', '/')
        with patch('ui.views._get_current_user') as m:
            u = _make_user()
            u.role = 'unknown'
            m.return_value = u
            r = views.home(req)
        self.assertIn('/login/', r['Location'])


# ---------------------------------------------------------------------------
# serve_media
# ---------------------------------------------------------------------------

class ServeMediaTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_path_traversal_raises_404(self):
        from django.http import Http404
        req = _req(self.f, 'get', '/media/../etc/passwd')
        with patch('ui.views.safe_join', side_effect=ValueError('bad')):
            with self.assertRaises(Http404):
                views.serve_media(req, '../etc/passwd')

    def test_missing_file_raises_404(self):
        from django.http import Http404
        req = _req(self.f, 'get', '/media/missing.png')
        with patch('ui.views.safe_join', return_value='/tmp/missing.png'), \
             patch('ui.views.os.path.exists', return_value=False):
            with self.assertRaises(Http404):
                views.serve_media(req, 'missing.png')

    def test_existing_file_returned(self):
        import io
        req = _req(self.f, 'get', '/media/test.png')
        fake_file = io.BytesIO(b'PNG_DATA')
        with patch('ui.views.safe_join', return_value='/tmp/test.png'), \
             patch('ui.views.os.path.exists', return_value=True), \
             patch('builtins.open', return_value=fake_file):
            r = views.serve_media(req, 'test.png')
        self.assertEqual(r.status_code, 200)


# ---------------------------------------------------------------------------
# Login view
# ---------------------------------------------------------------------------

class LoginViewTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_get_returns_200(self):
        req = _req(self.f, 'get', '/login/')
        self.assertEqual(views.login_view(req).status_code, 200)

    @patch('ui.views.AppUser.objects')
    @patch('ui.views.bcrypt.checkpw', return_value=False)
    def test_bad_credentials_rerenders(self, _chk, mock_mgr):
        mock_mgr.get.return_value = _make_user()
        req = _req(
            self.f, 'post', '/login/',
            data={'email': 'x@x.com', 'password': 'bad'},
        )
        req._messages = MagicMock()
        self.assertEqual(views.login_view(req).status_code, 200)

    @patch('ui.views.AppUser.objects')
    @patch('ui.views.bcrypt.checkpw', return_value=True)
    def test_student_redirects_to_assignments(self, _chk, mock_mgr):
        mock_mgr.get.return_value = _make_user(role='student')
        req = _req(
            self.f, 'post', '/login/',
            data={'email': 's@test.com', 'password': 'pw'},
        )
        req.session = {}
        r = views.login_view(req)
        self.assertIn('/student/assignments/', r['Location'])

    @patch('ui.views.AppUser.objects')
    @patch('ui.views.bcrypt.checkpw', return_value=True)
    def test_teacher_redirects_to_dashboard(self, _chk, mock_mgr):
        mock_mgr.get.return_value = _make_user(role='teacher')
        req = _req(
            self.f, 'post', '/login/',
            data={'email': 't@test.com', 'password': 'pw'},
        )
        req.session = {}
        r = views.login_view(req)
        self.assertIn('/teacher/', r['Location'])

    def test_logout_redirects_to_login(self):
        req = _req(self.f, 'get', '/logout/')
        req.session = MagicMock()
        r = views.logout_view(req)
        self.assertIn('/login/', r['Location'])


# ---------------------------------------------------------------------------
# Teacher: students list
# ---------------------------------------------------------------------------

class TeacherStudentsTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_get_renders_students(self):
        req = _req(self.f, 'get', '/teacher/students/')
        with patch('ui.views._get_current_user') as m, \
             _mock_render() as mock_rnd, \
             patch('ui.views.StudentProfile.objects') as mp:
            m.return_value = _make_user(role='teacher')
            mp.select_related.return_value.order_by.return_value = []
            r = views.teacher_students(req)
        self.assertEqual(r.status_code, 200)


# ---------------------------------------------------------------------------
# Teacher: add student
# ---------------------------------------------------------------------------

class TeacherAddStudentTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()
        self.user = _make_user(role='teacher')

    def _call(self, method, data=None):
        req = _req(self.f, method, '/teacher/students/add/', data=data)
        p1 = patch('ui.views._get_current_user', return_value=self.user)
        p2 = patch('ui.views.Grade.objects')
        return req, p1, p2

    def test_get_returns_200(self):
        req, p1, p2 = self._call('get')
        with p1, p2 as mock_grades, _mock_render():
            mock_grades.order_by.return_value = []
            r = views.teacher_add_student(req)
        self.assertEqual(r.status_code, 200)

    def test_post_missing_fields_rerenders(self):
        req, p1, p2 = self._call(
            'post',
            data={'first_name': '', 'last_name': '', 'email': ''},
        )
        req._messages = MagicMock()
        err, suc = _mock_messages()
        with p1, p2, err, suc, _mock_render():
            r = views.teacher_add_student(req)
        self.assertEqual(r.status_code, 200)

    def test_post_duplicate_email_rerenders(self):
        req, p1, p2 = self._call(
            'post',
            data={
                'first_name': 'A', 'last_name': 'B',
                'father_name': 'F', 'mother_name': 'M',
                'email': 'dup@test.com', 'contact': '123',
                'password': 'pw',
            },
        )
        err, suc = _mock_messages()
        with p1, p2, err, suc, _mock_render(), \
             patch('ui.views.AppUser.objects') as mock_mgr:
            mock_mgr.filter.return_value.exists.return_value = True
            r = views.teacher_add_student(req)
        self.assertEqual(r.status_code, 200)

    def test_post_success_redirects(self):
        req, p1, p2 = self._call(
            'post',
            data={
                'first_name': 'A', 'last_name': 'B',
                'father_name': 'F', 'mother_name': 'M',
                'email': 'new@test.com', 'contact': '123',
                'password': 'pw',
            },
        )
        err, suc = _mock_messages()
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        with p1, p2, err, suc, \
             patch('ui.views.AppUser.objects') as mock_usr, \
             patch('ui.views.StudentProfile.objects'), \
             patch('ui.views._save_profile_photo', return_value=''), \
             patch('ui.views.bcrypt.hashpw', return_value=b'hashed'), \
             patch('ui.views.transaction.atomic', return_value=ctx):
            mock_usr.filter.return_value.exists.return_value = False
            mock_usr.create.return_value = MagicMock(id=5)
            r = views.teacher_add_student(req)
        self.assertEqual(r.status_code, 302)


# ---------------------------------------------------------------------------
# Teacher: delete student
# ---------------------------------------------------------------------------

class TeacherDeleteStudentTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_delete_redirects(self):
        req = _req(self.f, 'post', '/teacher/students/1/delete/')
        profile = MagicMock()
        profile.profile_photo = None
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        err, suc = _mock_messages()
        with patch('ui.views._get_current_user') as m, \
             patch('ui.views.get_object_or_404', return_value=profile), \
             patch('ui.views.transaction.atomic', return_value=ctx), \
             patch('ui.views._delete_profile_photo'), \
             err, suc:
            m.return_value = _make_user(role='teacher')
            r = views.teacher_delete_student(req, student_id=1)
        self.assertEqual(r.status_code, 302)


# ---------------------------------------------------------------------------
# Teacher: profile
# ---------------------------------------------------------------------------

class TeacherProfileTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()
        self.user = _make_user(role='teacher')
        self.user.password = 'hashed'

    def test_get_renders_profile(self):
        req = _req(self.f, 'get', '/teacher/profile/')
        with patch('ui.views._get_current_user', return_value=self.user), \
             _mock_render():
            r = views.teacher_profile(req)
        self.assertEqual(r.status_code, 200)

    def test_post_missing_name_rerenders(self):
        req = _req(
            self.f, 'post', '/teacher/profile/',
            data={'name': '', 'email': 'a@b.com'},
        )
        err, suc = _mock_messages()
        with patch('ui.views._get_current_user', return_value=self.user), \
             err, suc, _mock_render():
            r = views.teacher_profile(req)
        self.assertEqual(r.status_code, 200)

    def test_post_no_password_change_redirects(self):
        req = _req(
            self.f, 'post', '/teacher/profile/',
            data={
                'name': 'Alice', 'email': 'alice@test.com',
                'current_password': '', 'new_password': '',
                'confirm_password': '',
            },
        )
        err, suc = _mock_messages()
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.AppUser.objects') as mock_mgr, \
             err, suc:
            mock_mgr.exclude.return_value.filter.return_value \
                .exists.return_value = False
            r = views.teacher_profile(req)
        self.assertEqual(r.status_code, 302)


# ---------------------------------------------------------------------------
# Teacher: create assignment
# ---------------------------------------------------------------------------

class TeacherCreateAssignmentTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()
        self.user = _make_user(role='teacher')

    def test_get_renders_form(self):
        req = _req(self.f, 'get', '/teacher/create-assignment/')
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.StudentProfile.objects') as ms, \
             patch('ui.views.Grade.objects') as mg, \
             patch('ui.views.Assignment.objects') as ma, \
             _mock_render():
            ms.select_related.return_value.order_by.return_value = []
            mg.prefetch_related.return_value.order_by.return_value = []
            ma.filter.return_value \
                .select_related.return_value \
                .order_by.return_value.first.return_value = None
            r = views.teacher_create_assignment(req)
        self.assertEqual(r.status_code, 200)

    def test_post_missing_student_rerenders(self):
        req = _req(
            self.f, 'post', '/teacher/create-assignment/',
            data={'assignment_mode': 'sprint'},
        )
        err, suc = _mock_messages()
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.StudentProfile.objects') as ms, \
             patch('ui.views.Grade.objects') as mg, \
             patch('ui.views.Assignment.objects') as ma, \
             err, suc, _mock_render():
            ms.select_related.return_value.order_by.return_value = []
            mg.prefetch_related.return_value.order_by.return_value = []
            ma.filter.return_value \
                .select_related.return_value \
                .order_by.return_value.first.return_value = None
            r = views.teacher_create_assignment(req)
        self.assertEqual(r.status_code, 200)


# ---------------------------------------------------------------------------
# Teacher: results
# ---------------------------------------------------------------------------

class TeacherResultsTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_get_no_student_renders(self):
        req = _req(self.f, 'get', '/teacher/results/')
        with patch('ui.views._get_current_user') as m, \
             patch('ui.views.StudentProfile.objects') as mp, \
             _mock_render():
            m.return_value = _make_user(role='teacher')
            mp.select_related.return_value.order_by.return_value = []
            r = views.teacher_results(req)
        self.assertEqual(r.status_code, 200)


# ---------------------------------------------------------------------------
# Teacher: unit attempts
# ---------------------------------------------------------------------------

class TeacherUnitAttemptsTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_missing_assignment_id_returns_400(self):
        req = _req(
            self.f, 'get',
            '/teacher/students/1/units/1/attempts/',
        )
        with patch('ui.views._get_current_user') as m:
            m.return_value = _make_user(role='teacher')
            r = views.teacher_student_unit_attempts(
                req, student_id=1, unit_id=1
            )
        self.assertEqual(r.status_code, 400)

    def test_with_assignment_id_returns_json(self):
        req = _req(
            self.f, 'get',
            '/teacher/students/1/units/1/attempts/',
            data={'assignment_id': '5'},
        )
        assignment = MagicMock()
        assignment.id = 5
        unit = MagicMock()
        unit.id = 1
        unit.unit_name = 'Unit 1'
        with patch('ui.views._get_current_user') as m, \
             patch('ui.views.get_object_or_404',
                   side_effect=[assignment, unit]), \
             patch('ui.views.CurriculumUnitAttempt.objects') as ma:
            m.return_value = _make_user(role='teacher')
            ma.filter.return_value \
                .prefetch_related.return_value \
                .order_by.return_value = []
            r = views.teacher_student_unit_attempts(
                req, student_id=1, unit_id=1
            )
        self.assertEqual(r.status_code, 200)
        data = json.loads(r.content)
        self.assertIn('attempts', data)


# ---------------------------------------------------------------------------
# Teacher: reset unit
# ---------------------------------------------------------------------------

class TeacherResetUnitTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_missing_assignment_id_returns_400(self):
        req = _req(
            self.f, 'post',
            '/teacher/students/1/units/1/reset/',
        )
        with patch('ui.views._get_current_user') as m:
            m.return_value = _make_user(role='teacher')
            r = views.teacher_reset_student_unit(
                req, student_id=1, unit_id=1
            )
        self.assertEqual(r.status_code, 400)

    def test_reset_returns_json(self):
        req = _req(
            self.f, 'post',
            '/teacher/students/1/units/1/reset/',
            data={'assignment_id': '5'},
        )
        assignment = MagicMock()
        assignment.id = 5
        with patch('ui.views._get_current_user') as m, \
             patch('ui.views.get_object_or_404',
                   side_effect=[assignment, MagicMock()]), \
             patch('ui.views.CurriculumUnitAttempt.objects') as ma:
            m.return_value = _make_user(role='teacher')
            ma.filter.return_value.delete.return_value = (3, {})
            r = views.teacher_reset_student_unit(
                req, student_id=1, unit_id=1
            )
        self.assertEqual(r.status_code, 200)
        self.assertIn('deleted', json.loads(r.content))


# ---------------------------------------------------------------------------
# Teacher: toys
# ---------------------------------------------------------------------------

class TeacherToysTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()
        self.user = _make_user(role='teacher')

    def test_get_renders_toys(self):
        req = _req(self.f, 'get', '/teacher/toys/')
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.Toy.objects') as mt, _mock_render():
            mt.order_by.return_value = []
            r = views.teacher_toys(req)
        self.assertEqual(r.status_code, 200)

    def test_post_add_missing_name_redirects(self):
        req = _req(
            self.f, 'post', '/teacher/toys/',
            data={'action': 'add', 'name': '', 'coin_value': '5'},
        )
        err, suc = _mock_messages()
        with patch('ui.views._get_current_user', return_value=self.user), \
             err, suc:
            r = views.teacher_toys(req)
        self.assertEqual(r.status_code, 302)

    def test_post_add_invalid_coin_value_redirects(self):
        req = _req(
            self.f, 'post', '/teacher/toys/',
            data={'action': 'add', 'name': 'Ball', 'coin_value': '0'},
        )
        err, suc = _mock_messages()
        with patch('ui.views._get_current_user', return_value=self.user), \
             err, suc:
            r = views.teacher_toys(req)
        self.assertEqual(r.status_code, 302)

    def test_post_add_success_redirects(self):
        req = _req(
            self.f, 'post', '/teacher/toys/',
            data={'action': 'add', 'name': 'Ball', 'coin_value': '3'},
        )
        err, suc = _mock_messages()
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.Toy.objects') as mt, \
             err, suc:
            mt.create.return_value = MagicMock()
            r = views.teacher_toys(req)
        self.assertEqual(r.status_code, 302)

    def test_post_delete_redirects(self):
        req = _req(
            self.f, 'post', '/teacher/toys/',
            data={'action': 'delete', 'toy_id': '1'},
        )
        toy = MagicMock()
        toy.image = None
        err, suc = _mock_messages()
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.get_object_or_404', return_value=toy), \
             patch('ui.views._delete_toy_image'), \
             err, suc:
            r = views.teacher_toys(req)
        self.assertEqual(r.status_code, 302)


# ---------------------------------------------------------------------------
# Teacher: student redemptions
# ---------------------------------------------------------------------------

class TeacherStudentRedemptionsTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_get_renders(self):
        req = _req(
            self.f, 'get',
            '/teacher/students/1/redemptions/',
        )
        profile = MagicMock()
        with patch('ui.views._get_current_user') as m, \
             patch('ui.views.get_object_or_404', return_value=profile), \
             patch('ui.views.ToyRedemption.objects') as mr, \
             _mock_render():
            m.return_value = _make_user(role='teacher')
            mr.filter.return_value \
                .select_related.return_value \
                .order_by.return_value = []
            r = views.teacher_student_redemptions(req, student_id=1)
        self.assertEqual(r.status_code, 200)


# ---------------------------------------------------------------------------
# Student: dashboard
# ---------------------------------------------------------------------------

class StudentDashboardTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_get_renders(self):
        req = _req(self.f, 'get', '/student/')
        with patch('ui.views._get_current_user') as m, \
             patch('ui.views.StudentProfile.objects') as mp, \
             patch('ui.views._student_available_assignments',
                   return_value=[]), \
             patch('ui.views._populate_student_assignment_totals'), \
             _mock_render():
            m.return_value = _make_user(role='student')
            profile = MagicMock()
            profile.grade_id = 1
            profile.grade = MagicMock()
            profile.grade.grade_name = 'Grade 1'
            mp.select_related.return_value \
                .filter.return_value.first.return_value = profile
            r = views.student_dashboard(req)
        self.assertEqual(r.status_code, 200)


# ---------------------------------------------------------------------------
# Student: redeem toy
# ---------------------------------------------------------------------------

class StudentRedeemToyTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()
        self.user = _make_user(role='student')

    def _post(self, data):
        req = _req(
            self.f, 'post', '/student/coins/redeem/', data=data
        )
        with patch('ui.views._get_current_user', return_value=self.user):
            return views.student_redeem_toy(req)

    def test_missing_toy_id_returns_400(self):
        with patch('ui.views._get_current_user', return_value=self.user):
            req = _req(self.f, 'post', '/student/coins/redeem/')
            r = views.student_redeem_toy(req)
        self.assertEqual(r.status_code, 400)

    @patch('ui.views.get_object_or_404')
    def test_no_profile_returns_400(self, mock_404):
        toy = MagicMock()
        toy.coin_value = 5
        mock_404.return_value = toy
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.StudentProfile.objects') as mp, \
             patch('ui.views.transaction.atomic', return_value=ctx):
            mp.select_for_update.return_value \
                .filter.return_value.first.return_value = None
            req = _req(
                self.f, 'post', '/student/coins/redeem/',
                data={'toy_id': '1'},
            )
            r = views.student_redeem_toy(req)
        self.assertEqual(r.status_code, 400)
        self.assertIn('not found', json.loads(r.content)['message'])

    @patch('ui.views.get_object_or_404')
    def test_not_enough_coins_returns_400(self, mock_404):
        toy = MagicMock()
        toy.coin_value = 100
        mock_404.return_value = toy
        profile = MagicMock()
        profile.coins = 5
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.StudentProfile.objects') as mp, \
             patch('ui.views.transaction.atomic', return_value=ctx):
            mp.select_for_update.return_value \
                .filter.return_value.first.return_value = profile
            req = _req(
                self.f, 'post', '/student/coins/redeem/',
                data={'toy_id': '1'},
            )
            r = views.student_redeem_toy(req)
        self.assertEqual(r.status_code, 400)
        self.assertIn('coins', json.loads(r.content)['message'])

    @patch('ui.views.get_object_or_404')
    def test_successful_redemption_returns_200(self, mock_404):
        toy = MagicMock()
        toy.id = 1
        toy.name = 'Ball'
        toy.coin_value = 5
        mock_404.return_value = toy
        profile = MagicMock()
        profile.coins = 20
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.StudentProfile.objects') as mp, \
             patch('ui.views.ToyRedemption.objects'), \
             patch('ui.views.transaction.atomic', return_value=ctx):
            mp.select_for_update.return_value \
                .filter.return_value.first.return_value = profile
            req = _req(
                self.f, 'post', '/student/coins/redeem/',
                data={'toy_id': '1'},
            )
            r = views.student_redeem_toy(req)
        self.assertEqual(r.status_code, 200)
        data = json.loads(r.content)
        self.assertIn('Ball', data['message'])


# ---------------------------------------------------------------------------
# student_submit_unit_question — validation
# ---------------------------------------------------------------------------

class UnitSubmitValidationTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def _post(self, data):
        req = _req(
            self.f, 'post',
            '/student/unit-practice/submit/', data=data,
        )
        with patch('ui.views._get_current_user') as m:
            m.return_value = _make_user()
            return views.student_submit_unit_question(req)

    def test_missing_unit_id(self):
        r = self._post({
            'question_id': '1', 'assignment_id': '1',
            'student_answer': '42',
        })
        self.assertEqual(r.status_code, 400)
        self.assertIn('required', json.loads(r.content)['message'])

    def test_missing_question_id(self):
        r = self._post({
            'unit_id': '1', 'assignment_id': '1',
            'student_answer': '42',
        })
        self.assertEqual(r.status_code, 400)

    def test_missing_assignment_id(self):
        r = self._post({
            'unit_id': '1', 'question_id': '1',
            'student_answer': '42',
        })
        self.assertEqual(r.status_code, 400)

    def test_invalid_elapsed_seconds(self):
        r = self._post({
            'unit_id': '1', 'question_id': '1',
            'assignment_id': '1', 'student_answer': '42',
            'elapsed_seconds': 'xyz',
        })
        self.assertEqual(r.status_code, 400)

    @patch('ui.views.get_object_or_404')
    @patch('ui.views.truncate_numeric_precision', return_value='')
    def test_empty_answer_returns_400(self, _tr, mock_404):
        a = MagicMock()
        a.lesson_id = 10
        u = MagicMock()
        u.sub_lesson.lesson_type_id = 10
        mock_404.side_effect = [a, u, MagicMock()]
        r = self._post({
            'unit_id': '1', 'question_id': '1',
            'assignment_id': '1', 'student_answer': '',
        })
        self.assertEqual(r.status_code, 400)

    @patch('ui.views.get_object_or_404')
    def test_wrong_lesson_returns_400(self, mock_404):
        a = MagicMock()
        a.lesson_id = 10
        u = MagicMock()
        u.sub_lesson.lesson_type_id = 99
        mock_404.side_effect = [a, u, MagicMock()]
        r = self._post({
            'unit_id': '1', 'question_id': '1',
            'assignment_id': '1', 'student_answer': '5',
        })
        self.assertEqual(r.status_code, 400)
        self.assertIn('does not belong', json.loads(r.content)['message'])

    def test_get_not_allowed(self):
        req = _req(
            self.f, 'get', '/student/unit-practice/submit/'
        )
        with patch('ui.views._get_current_user') as m:
            m.return_value = _make_user()
            r = views.student_submit_unit_question(req)
        self.assertEqual(r.status_code, 405)


# ---------------------------------------------------------------------------
# student_submit — response shape and retry logic
# ---------------------------------------------------------------------------

class UnitSubmitResponseTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def _submit(
        self, student_answer, correct_answer,
        prior_status=None, attempt_num=1, total_questions=5,
    ):
        """
        prior_status: None (first ever attempt),
                      'passed'/'failed' (triggers new attempt)
        """
        user = _make_user()
        assignment = MagicMock()
        assignment.id = 1
        assignment.lesson_id = 10

        unit = MagicMock()
        unit.id = 1
        unit.sub_lesson.lesson_type_id = 10
        unit.curriculum_questions.count.return_value = total_questions

        question = MagicMock()
        question.id = 1
        question.answer_text = correct_answer

        is_right = (student_answer == correct_answer)
        attempt = MagicMock()
        attempt.id = 99
        attempt.attempt_number = attempt_num
        attempt.elapsed_seconds = 0
        attempt.status = 'in_progress'
        attempt.correct_count = 0
        attempt.wrong_count = 0
        attempt.question_attempts.all.return_value = [
            MagicMock(is_correct=is_right)
        ]

        if prior_status:
            prior = MagicMock()
            prior.status = prior_status
            prior.attempt_number = attempt_num - 1
        else:
            prior = None

        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)

        req = _req(
            self.f, 'post',
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
            patch(
                'ui.views.CurriculumQuestionAttempt.objects'
            ) as mock_qa, \
            patch('ui.views.StudentProfile.objects'), \
            patch('ui.views.transaction.atomic', return_value=ctx):

            mock_att.filter.return_value \
                .order_by.return_value.first.return_value = prior
            mock_att.create.return_value = attempt
            mock_qa.get_or_create.return_value = (MagicMock(), True)

            return views.student_submit_unit_question(req)

    def test_correct_answer_shape(self):
        data = json.loads(self._submit('42', '42').content)
        for k in (
            'is_correct', 'status', 'correct_count', 'wrong_count',
            'is_complete', 'attempt_status', 'attempt_number',
            'coins_awarded',
        ):
            self.assertIn(k, data)

    def test_correct_answer_is_correct_true(self):
        data = json.loads(self._submit('42', '42').content)
        self.assertTrue(data['is_correct'])
        self.assertEqual(data['status'], 'correct')

    def test_incorrect_answer_is_correct_false(self):
        data = json.loads(self._submit('99', '42').content)
        self.assertFalse(data['is_correct'])
        self.assertEqual(data['status'], 'incorrect')

    def test_retry_after_passed_creates_new_attempt(self):
        # Prior attempt was 'passed' → should trigger new attempt creation
        r = self._submit(
            '42', '42', prior_status='passed', attempt_num=2
        )
        self.assertEqual(r.status_code, 200)
        data = json.loads(r.content)
        self.assertEqual(data['attempt_number'], 2)

    def test_retry_after_failed_creates_new_attempt(self):
        r = self._submit(
            '5', '5', prior_status='failed', attempt_num=2
        )
        self.assertEqual(r.status_code, 200)


# ---------------------------------------------------------------------------
# Assignment model constants
# ---------------------------------------------------------------------------

class AssignmentModelConstantsTest(SimpleTestCase):

    def test_modes(self):
        from core.models import Assignment
        self.assertEqual(Assignment.MODE_SPRINT, 'sprint')
        self.assertEqual(Assignment.MODE_STANDARD, 'standard')
        self.assertEqual(Assignment.MODE_LOCK, 'lock')

    def test_mode_choices(self):
        from core.models import Assignment
        values = [m[0] for m in Assignment.MODE_CHOICES]
        for mode in ('sprint', 'standard', 'lock'):
            self.assertIn(mode, values)

    def test_kinds(self):
        from core.models import Assignment
        self.assertEqual(Assignment.KIND_HOMEWORK, 'homework')
        self.assertEqual(Assignment.KIND_CLASSROOM, 'classroom')


# ---------------------------------------------------------------------------
# Assignment mode validation
# ---------------------------------------------------------------------------

class AssignmentModeValidationTest(SimpleTestCase):

    def _val(self, raw):
        from core.models import Assignment
        mode = (raw or '').strip()
        if mode not in {
            Assignment.MODE_SPRINT,
            Assignment.MODE_STANDARD,
            Assignment.MODE_LOCK,
        }:
            mode = Assignment.MODE_SPRINT
        return mode

    def test_sprint(self): self.assertEqual(self._val('sprint'), 'sprint')
    def test_standard(self): self.assertEqual(self._val('standard'), 'standard')
    def test_lock(self): self.assertEqual(self._val('lock'), 'lock')
    def test_empty(self): self.assertEqual(self._val(''), 'sprint')
    def test_unknown(self): self.assertEqual(self._val('bad'), 'sprint')
    def test_uppercase(self): self.assertEqual(self._val('SPRINT'), 'sprint')
    def test_none(self): self.assertEqual(self._val(None), 'sprint')
