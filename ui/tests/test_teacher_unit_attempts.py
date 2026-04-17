import json
from unittest.mock import MagicMock, patch

from django.test import RequestFactory, SimpleTestCase

import ui.views as views
from ui.tests.helpers import make_req, make_user


class TeacherUnitAttemptsTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_missing_assignment_id_returns_400(self):
        req = make_req(self.f, 'get', '/teacher/students/1/units/1/attempts/')
        with patch('ui.views._get_current_user', return_value=make_user(role='teacher')):
            r = views.teacher_student_unit_attempts(req, student_id=1, unit_id=1)
        self.assertEqual(r.status_code, 400)

    def test_with_assignment_id_returns_json(self):
        req = make_req(self.f, 'get', '/teacher/students/1/units/1/attempts/',
                       data={'assignment_id': '5'})
        assignment = MagicMock()
        assignment.id = 5
        unit = MagicMock()
        unit.id = 1
        unit.unit_name = 'Unit 1'
        with patch('ui.views._get_current_user', return_value=make_user(role='teacher')), \
             patch('ui.views.get_object_or_404', side_effect=[assignment, unit]), \
             patch('ui.views.CurriculumUnitAttempt.objects') as ma:
            ma.filter.return_value \
                .prefetch_related.return_value \
                .order_by.return_value = []
            r = views.teacher_student_unit_attempts(req, student_id=1, unit_id=1)
        self.assertEqual(r.status_code, 200)
        self.assertIn('attempts', json.loads(r.content))


class TeacherResetUnitTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_missing_assignment_id_returns_400(self):
        req = make_req(self.f, 'post', '/teacher/students/1/units/1/reset/')
        with patch('ui.views._get_current_user', return_value=make_user(role='teacher')):
            r = views.teacher_reset_student_unit(req, student_id=1, unit_id=1)
        self.assertEqual(r.status_code, 400)

    def test_reset_returns_json(self):
        req = make_req(self.f, 'post', '/teacher/students/1/units/1/reset/',
                       data={'assignment_id': '5'})
        assignment = MagicMock()
        assignment.id = 5
        with patch('ui.views._get_current_user', return_value=make_user(role='teacher')), \
             patch('ui.views.get_object_or_404', side_effect=[assignment, MagicMock()]), \
             patch('ui.views.CurriculumUnitAttempt.objects') as ma:
            ma.filter.return_value.delete.return_value = (3, {})
            r = views.teacher_reset_student_unit(req, student_id=1, unit_id=1)
        self.assertEqual(r.status_code, 200)
        self.assertIn('deleted', json.loads(r.content))
