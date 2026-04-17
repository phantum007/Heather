from django.test import SimpleTestCase

import core.views as api_views
from core.tests.helpers import api_req


class HealthViewTest(SimpleTestCase):

    def test_get_returns_ok(self):
        r = api_views.HealthView.as_view()(api_req('get', '/api/health/'))
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.data['status'], 'ok')

    def test_get_contains_service_name(self):
        r = api_views.HealthView.as_view()(api_req('get', '/api/health/'))
        self.assertIn('service', r.data)
