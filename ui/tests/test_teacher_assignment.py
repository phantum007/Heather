from unittest.mock import patch

from django.test import RequestFactory, SimpleTestCase

import ui.views as views
from ui.tests.helpers import make_req, make_user, mock_messages, mock_render


class TeacherCreateAssignmentTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()
        self.user = make_user(role='teacher')

    def test_get_renders_form(self):
        req = make_req(self.f, 'get', '/teacher/create-assignment/')
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.StudentProfile.objects') as ms, \
             patch('ui.views.Grade.objects') as mg, \
             patch('ui.views.Assignment.objects') as ma, \
             mock_render():
            ms.select_related.return_value.order_by.return_value = []
            mg.prefetch_related.return_value.order_by.return_value = []
            ma.filter.return_value \
                .select_related.return_value \
                .order_by.return_value.first.return_value = None
            r = views.teacher_create_assignment(req)
        self.assertEqual(r.status_code, 200)

    def test_post_missing_student_rerenders(self):
        req = make_req(self.f, 'post', '/teacher/create-assignment/',
                       data={'assignment_mode': 'sprint'})
        err, suc = mock_messages()
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.StudentProfile.objects') as ms, \
             patch('ui.views.Grade.objects') as mg, \
             patch('ui.views.Assignment.objects') as ma, \
             err, suc, mock_render():
            ms.select_related.return_value.order_by.return_value = []
            mg.prefetch_related.return_value.order_by.return_value = []
            ma.filter.return_value \
                .select_related.return_value \
                .order_by.return_value.first.return_value = None
            r = views.teacher_create_assignment(req)
        self.assertEqual(r.status_code, 200)


class TeacherResultsTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_get_no_student_renders(self):
        req = make_req(self.f, 'get', '/teacher/results/')
        with patch('ui.views._get_current_user', return_value=make_user(role='teacher')), \
             patch('ui.views.StudentProfile.objects') as mp, \
             mock_render():
            mp.select_related.return_value.order_by.return_value = []
            r = views.teacher_results(req)
        self.assertEqual(r.status_code, 200)
