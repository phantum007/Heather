from unittest.mock import patch

from django.test import RequestFactory, SimpleTestCase

import ui.views as views
from ui.tests.helpers import make_req, make_user, mock_messages, mock_render


class TeacherProfileTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()
        self.user = make_user(role='teacher')
        self.user.password = 'hashed'

    def test_get_renders_profile(self):
        req = make_req(self.f, 'get', '/teacher/profile/')
        with patch('ui.views._get_current_user', return_value=self.user), mock_render():
            r = views.teacher_profile(req)
        self.assertEqual(r.status_code, 200)

    def test_post_missing_name_rerenders(self):
        req = make_req(self.f, 'post', '/teacher/profile/', data={'name': '', 'email': 'a@b.com'})
        err, suc = mock_messages()
        with patch('ui.views._get_current_user', return_value=self.user), \
             err, suc, mock_render():
            r = views.teacher_profile(req)
        self.assertEqual(r.status_code, 200)

    def test_post_no_password_change_redirects(self):
        req = make_req(self.f, 'post', '/teacher/profile/', data={
            'name': 'Alice', 'email': 'alice@test.com',
            'current_password': '', 'new_password': '', 'confirm_password': '',
        })
        err, suc = mock_messages()
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.AppUser.objects') as mock_mgr, \
             err, suc:
            mock_mgr.exclude.return_value.filter.return_value.exists.return_value = False
            r = views.teacher_profile(req)
        self.assertEqual(r.status_code, 302)
