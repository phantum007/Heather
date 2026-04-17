from unittest.mock import patch

from django.test import RequestFactory, SimpleTestCase

import ui.views as views
from ui.tests.helpers import make_req, make_user


class AuthGuardTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_student_assignments_requires_auth(self):
        r = views.student_assignments(make_req(self.f, 'get', '/student/assignments/'))
        self.assertEqual(r.status_code, 302)
        self.assertIn('/login/', r['Location'])

    def test_student_coins_requires_auth(self):
        r = views.student_coins(make_req(self.f, 'get', '/student/coins/'))
        self.assertEqual(r.status_code, 302)

    def test_teacher_dashboard_requires_auth(self):
        r = views.teacher_dashboard(make_req(self.f, 'get', '/teacher/'))
        self.assertEqual(r.status_code, 302)

    def test_student_blocked_from_teacher_view(self):
        req = make_req(self.f, 'get', '/teacher/', session_user_id=1)
        with patch('ui.views._get_current_user', return_value=make_user(role='student')):
            r = views.teacher_dashboard(req)
        self.assertEqual(r.status_code, 403)

    def test_teacher_blocked_from_student_view(self):
        req = make_req(self.f, 'get', '/student/assignments/', session_user_id=1)
        with patch('ui.views._get_current_user', return_value=make_user(role='teacher')):
            r = views.student_assignments(req)
        self.assertEqual(r.status_code, 403)
