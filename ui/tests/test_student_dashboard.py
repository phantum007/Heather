from unittest.mock import MagicMock, patch

from django.test import RequestFactory, SimpleTestCase

import ui.views as views
from ui.tests.helpers import make_req, make_user, mock_render


class StudentDashboardTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_get_renders(self):
        req = make_req(self.f, 'get', '/student/')
        with patch('ui.views._get_current_user', return_value=make_user(role='student')), \
             patch('ui.views.StudentProfile.objects') as mp, \
             patch('ui.views._student_available_assignments', return_value=[]), \
             patch('ui.views._populate_student_assignment_totals'), \
             mock_render():
            profile = MagicMock()
            profile.grade_id = 1
            profile.grade = MagicMock()
            profile.grade.grade_name = 'Grade 1'
            mp.select_related.return_value.filter.return_value.first.return_value = profile
            r = views.student_dashboard(req)
        self.assertEqual(r.status_code, 200)
