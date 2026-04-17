from unittest.mock import patch

from django.test import RequestFactory, SimpleTestCase

import ui.views as views
from ui.tests.helpers import make_req, make_user


class HomeViewTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_no_user_redirects_to_login(self):
        r = views.home(make_req(self.f, 'get', '/'))
        self.assertIn('/login/', r['Location'])

    def test_teacher_redirects_to_dashboard(self):
        req = make_req(self.f, 'get', '/')
        with patch('ui.views._get_current_user', return_value=make_user(role='teacher')):
            r = views.home(req)
        self.assertIn('/teacher/', r['Location'])

    def test_student_redirects_to_assignments(self):
        req = make_req(self.f, 'get', '/')
        with patch('ui.views._get_current_user', return_value=make_user(role='student')):
            r = views.home(req)
        self.assertIn('/student/assignments/', r['Location'])

    def test_unknown_role_redirects_to_login(self):
        req = make_req(self.f, 'get', '/')
        u = make_user()
        u.role = 'unknown'
        with patch('ui.views._get_current_user', return_value=u):
            r = views.home(req)
        self.assertIn('/login/', r['Location'])
