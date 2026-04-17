import io
from unittest.mock import patch

from django.test import RequestFactory, SimpleTestCase

import ui.views as views
from ui.tests.helpers import make_req


class ServeMediaTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def test_path_traversal_raises_404(self):
        from django.http import Http404
        req = make_req(self.f, 'get', '/media/../etc/passwd')
        with patch('ui.views.safe_join', side_effect=ValueError('bad')):
            with self.assertRaises(Http404):
                views.serve_media(req, '../etc/passwd')

    def test_missing_file_raises_404(self):
        from django.http import Http404
        req = make_req(self.f, 'get', '/media/missing.png')
        with patch('ui.views.safe_join', return_value='/tmp/missing.png'), \
             patch('ui.views.os.path.exists', return_value=False):
            with self.assertRaises(Http404):
                views.serve_media(req, 'missing.png')

    def test_existing_file_returned(self):
        req = make_req(self.f, 'get', '/media/test.png')
        fake_file = io.BytesIO(b'PNG_DATA')
        with patch('ui.views.safe_join', return_value='/tmp/test.png'), \
             patch('ui.views.os.path.exists', return_value=True), \
             patch('builtins.open', return_value=fake_file):
            r = views.serve_media(req, 'test.png')
        self.assertEqual(r.status_code, 200)
