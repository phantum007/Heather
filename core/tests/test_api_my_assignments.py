from unittest.mock import patch

from django.test import SimpleTestCase

import core.views as api_views
from core.tests.helpers import api_req, make_user


class MyAssignmentsViewTest(SimpleTestCase):

    def test_get_returns_list(self):
        user = make_user(role='student')
        req = api_req('get', '/api/my-assignments/', user=user)
        with patch('core.views.IsStudent.has_permission', return_value=True), \
             patch('core.views.IsAuthenticatedUser.has_permission', return_value=True), \
             patch('core.views.Assignment.objects') as ma, \
             patch('core.views.StudentAnswer.objects'):
            ma.filter.return_value \
                .select_related.return_value \
                .prefetch_related.return_value \
                .annotate.return_value \
                .order_by.return_value = []
            r = api_views.MyAssignmentsView.as_view()(req)
        self.assertEqual(r.status_code, 200)
        self.assertIsInstance(r.data, list)
