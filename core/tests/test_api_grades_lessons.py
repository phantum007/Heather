from unittest.mock import MagicMock, patch

from django.test import SimpleTestCase

import core.views as api_views
from core.tests.helpers import api_req, make_user


class GradesLessonsViewTest(SimpleTestCase):

    def test_get_returns_list(self):
        user = make_user(role='teacher')
        req = api_req('get', '/api/grades-lessons/', user=user)
        grade = MagicMock()
        grade.id = 1
        grade.grade_name = 'Grade 1'
        grade.lesson_types.all.return_value.order_by.return_value = []
        with patch('core.views.IsTeacher.has_permission', return_value=True), \
             patch('core.views.IsAuthenticatedUser.has_permission', return_value=True), \
             patch('core.views.Grade.objects') as mg:
            mg.prefetch_related.return_value.order_by.return_value = [grade]
            r = api_views.GradesLessonsView.as_view()(req)
        self.assertEqual(r.status_code, 200)
        self.assertIsInstance(r.data, list)
