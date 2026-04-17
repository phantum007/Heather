from unittest.mock import MagicMock, patch

from django.test import RequestFactory, SimpleTestCase

import ui.views as views
from ui.tests.helpers import make_req, make_user, mock_messages, mock_render


class TeacherToysTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()
        self.user = make_user(role='teacher')

    def test_get_renders_toys(self):
        req = make_req(self.f, 'get', '/teacher/toys/')
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.Toy.objects') as mt, mock_render():
            mt.order_by.return_value = []
            r = views.teacher_toys(req)
        self.assertEqual(r.status_code, 200)

    def test_post_add_missing_name_redirects(self):
        req = make_req(self.f, 'post', '/teacher/toys/',
                       data={'action': 'add', 'name': '', 'coin_value': '5'})
        err, suc = mock_messages()
        with patch('ui.views._get_current_user', return_value=self.user), err, suc:
            r = views.teacher_toys(req)
        self.assertEqual(r.status_code, 302)

    def test_post_add_invalid_coin_value_redirects(self):
        req = make_req(self.f, 'post', '/teacher/toys/',
                       data={'action': 'add', 'name': 'Ball', 'coin_value': '0'})
        err, suc = mock_messages()
        with patch('ui.views._get_current_user', return_value=self.user), err, suc:
            r = views.teacher_toys(req)
        self.assertEqual(r.status_code, 302)

    def test_post_add_success_redirects(self):
        req = make_req(self.f, 'post', '/teacher/toys/',
                       data={'action': 'add', 'name': 'Ball', 'coin_value': '3'})
        err, suc = mock_messages()
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.Toy.objects') as mt, err, suc:
            mt.create.return_value = MagicMock()
            r = views.teacher_toys(req)
        self.assertEqual(r.status_code, 302)

    def test_post_delete_redirects(self):
        req = make_req(self.f, 'post', '/teacher/toys/',
                       data={'action': 'delete', 'toy_id': '1'})
        toy = MagicMock()
        toy.image = None
        err, suc = mock_messages()
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.get_object_or_404', return_value=toy), \
             patch('ui.views._delete_toy_image'), err, suc:
            r = views.teacher_toys(req)
        self.assertEqual(r.status_code, 302)


class TeacherStudentRedemptionsTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_get_renders(self):
        req = make_req(self.f, 'get', '/teacher/students/1/redemptions/')
        profile = MagicMock()
        with patch('ui.views._get_current_user', return_value=make_user(role='teacher')), \
             patch('ui.views.get_object_or_404', return_value=profile), \
             patch('ui.views.ToyRedemption.objects') as mr, mock_render():
            mr.filter.return_value \
                .select_related.return_value \
                .order_by.return_value = []
            r = views.teacher_student_redemptions(req, student_id=1)
        self.assertEqual(r.status_code, 200)
