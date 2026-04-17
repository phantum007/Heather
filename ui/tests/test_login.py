from unittest.mock import MagicMock, patch

from django.test import RequestFactory, SimpleTestCase

import ui.views as views
from ui.tests.helpers import make_req, make_user


class LoginViewTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_get_returns_200(self):
        self.assertEqual(views.login_view(make_req(self.f, 'get', '/login/')).status_code, 200)

    @patch('ui.views.AppUser.objects')
    @patch('ui.views.bcrypt.checkpw', return_value=False)
    def test_bad_credentials_rerenders(self, _chk, mock_mgr):
        mock_mgr.get.return_value = make_user()
        req = make_req(self.f, 'post', '/login/', data={'email': 'x@x.com', 'password': 'bad'})
        req._messages = MagicMock()
        self.assertEqual(views.login_view(req).status_code, 200)

    @patch('ui.views.AppUser.objects')
    @patch('ui.views.bcrypt.checkpw', return_value=True)
    def test_student_redirects_to_assignments(self, _chk, mock_mgr):
        mock_mgr.get.return_value = make_user(role='student')
        req = make_req(self.f, 'post', '/login/', data={'email': 's@test.com', 'password': 'pw'})
        req.session = {}
        r = views.login_view(req)
        self.assertIn('/student/assignments/', r['Location'])

    @patch('ui.views.AppUser.objects')
    @patch('ui.views.bcrypt.checkpw', return_value=True)
    def test_teacher_redirects_to_dashboard(self, _chk, mock_mgr):
        mock_mgr.get.return_value = make_user(role='teacher')
        req = make_req(self.f, 'post', '/login/', data={'email': 't@test.com', 'password': 'pw'})
        req.session = {}
        r = views.login_view(req)
        self.assertIn('/teacher/', r['Location'])

    def test_logout_redirects_to_login(self):
        req = make_req(self.f, 'get', '/logout/')
        req.session = MagicMock()
        r = views.logout_view(req)
        self.assertIn('/login/', r['Location'])
