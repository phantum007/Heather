from unittest.mock import MagicMock, patch

from django.test import SimpleTestCase

import core.views as api_views
from core.tests.helpers import api_req, make_user


class StudentsViewTest(SimpleTestCase):

    def test_get_returns_list(self):
        user = make_user(role='teacher')
        req = api_req('get', '/api/students/', user=user)
        profile = MagicMock()
        profile.user.id = 2
        profile.user.name = 'Student'
        profile.user.email = 's@test.com'
        profile.grade_id = 1
        profile.grade = MagicMock()
        profile.grade.grade_name = 'Grade 1'
        with patch('core.views.IsTeacher.has_permission', return_value=True), \
             patch('core.views.IsAuthenticatedUser.has_permission', return_value=True), \
             patch('core.views.StudentProfile.objects') as mp:
            mp.select_related.return_value.order_by.return_value = [profile]
            r = api_views.StudentsView.as_view()(req)
        self.assertEqual(r.status_code, 200)
        self.assertIsInstance(r.data, list)
