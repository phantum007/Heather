from unittest.mock import patch

from django.test import SimpleTestCase

import core.views as api_views
from core.tests.helpers import api_req, make_user


class TeacherProfileViewTest(SimpleTestCase):

    def test_get_returns_user(self):
        user = make_user(role='teacher')
        req = api_req('get', '/api/teacher/profile/', user=user)
        with patch('core.views.IsTeacher.has_permission', return_value=True), \
             patch('core.views.IsAuthenticatedUser.has_permission', return_value=True):
            r = api_views.TeacherProfileView.as_view()(req)
        self.assertEqual(r.status_code, 200)
        self.assertIn('user', r.data)

    def test_patch_invalid_returns_400(self):
        user = make_user(role='teacher')
        req = api_req('patch', '/api/teacher/profile/', data={}, user=user)
        with patch('core.serializers.AppUser.objects') as mock_mgr:
            mock_mgr.exclude.return_value.filter.return_value.exists.return_value = False
            r = api_views.TeacherProfileView.as_view()(req)
        self.assertEqual(r.status_code, 400)
