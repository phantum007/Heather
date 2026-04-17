from unittest.mock import MagicMock, patch

from django.test import RequestFactory, SimpleTestCase

import ui.views as views
from ui.tests.helpers import make_req, make_user, mock_messages, mock_render


class TeacherStudentsTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_get_renders_students(self):
        req = make_req(self.f, 'get', '/teacher/students/')
        with patch('ui.views._get_current_user', return_value=make_user(role='teacher')), \
             mock_render() as mock_rnd, \
             patch('ui.views.StudentProfile.objects') as mp:
            mp.select_related.return_value.order_by.return_value = []
            r = views.teacher_students(req)
        self.assertEqual(r.status_code, 200)


class TeacherAddStudentTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()
        self.user = make_user(role='teacher')

    def _call(self, method, data=None):
        req = make_req(self.f, method, '/teacher/students/add/', data=data)
        p1 = patch('ui.views._get_current_user', return_value=self.user)
        p2 = patch('ui.views.Grade.objects')
        return req, p1, p2

    def test_get_returns_200(self):
        req, p1, p2 = self._call('get')
        with p1, p2 as mock_grades, mock_render():
            mock_grades.order_by.return_value = []
            r = views.teacher_add_student(req)
        self.assertEqual(r.status_code, 200)

    def test_post_missing_fields_rerenders(self):
        req, p1, p2 = self._call('post', data={'first_name': '', 'last_name': '', 'email': ''})
        req._messages = MagicMock()
        err, suc = mock_messages()
        with p1, p2, err, suc, mock_render():
            r = views.teacher_add_student(req)
        self.assertEqual(r.status_code, 200)

    def test_post_duplicate_email_rerenders(self):
        req, p1, p2 = self._call('post', data={
            'first_name': 'A', 'last_name': 'B', 'father_name': 'F', 'mother_name': 'M',
            'email': 'dup@test.com', 'contact': '123', 'password': 'pw',
        })
        err, suc = mock_messages()
        with p1, p2, err, suc, mock_render(), \
             patch('ui.views.AppUser.objects') as mock_mgr:
            mock_mgr.filter.return_value.exists.return_value = True
            r = views.teacher_add_student(req)
        self.assertEqual(r.status_code, 200)

    def test_post_success_redirects(self):
        req, p1, p2 = self._call('post', data={
            'first_name': 'A', 'last_name': 'B', 'father_name': 'F', 'mother_name': 'M',
            'email': 'new@test.com', 'contact': '123', 'password': 'pw',
        })
        err, suc = mock_messages()
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


class TeacherDeleteStudentTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_delete_redirects(self):
        req = make_req(self.f, 'post', '/teacher/students/1/delete/')
        profile = MagicMock()
        profile.profile_photo = None
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        err, suc = mock_messages()
        with patch('ui.views._get_current_user', return_value=make_user(role='teacher')), \
             patch('ui.views.get_object_or_404', return_value=profile), \
             patch('ui.views.transaction.atomic', return_value=ctx), \
             patch('ui.views._delete_profile_photo'), \
             err, suc:
            r = views.teacher_delete_student(req, student_id=1)
        self.assertEqual(r.status_code, 302)
