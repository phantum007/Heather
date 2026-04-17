import json
from unittest.mock import MagicMock, patch

from django.test import RequestFactory, SimpleTestCase

import ui.views as views
from ui.tests.helpers import make_req, make_user


class StudentRedeemToyTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()
        self.user = make_user(role='student')

    def test_missing_toy_id_returns_400(self):
        req = make_req(self.f, 'post', '/student/coins/redeem/')
        with patch('ui.views._get_current_user', return_value=self.user):
            r = views.student_redeem_toy(req)
        self.assertEqual(r.status_code, 400)

    @patch('ui.views.get_object_or_404')
    def test_no_profile_returns_400(self, mock_404):
        toy = MagicMock()
        toy.coin_value = 5
        mock_404.return_value = toy
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.StudentProfile.objects') as mp, \
             patch('ui.views.transaction.atomic', return_value=ctx):
            mp.select_for_update.return_value.filter.return_value.first.return_value = None
            req = make_req(self.f, 'post', '/student/coins/redeem/', data={'toy_id': '1'})
            r = views.student_redeem_toy(req)
        self.assertEqual(r.status_code, 400)
        self.assertIn('not found', json.loads(r.content)['message'])

    @patch('ui.views.get_object_or_404')
    def test_not_enough_coins_returns_400(self, mock_404):
        toy = MagicMock()
        toy.coin_value = 100
        mock_404.return_value = toy
        profile = MagicMock()
        profile.coins = 5
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.StudentProfile.objects') as mp, \
             patch('ui.views.transaction.atomic', return_value=ctx):
            mp.select_for_update.return_value.filter.return_value.first.return_value = profile
            req = make_req(self.f, 'post', '/student/coins/redeem/', data={'toy_id': '1'})
            r = views.student_redeem_toy(req)
        self.assertEqual(r.status_code, 400)
        self.assertIn('coins', json.loads(r.content)['message'])

    @patch('ui.views.get_object_or_404')
    def test_successful_redemption_returns_200(self, mock_404):
        toy = MagicMock()
        toy.id = 1
        toy.name = 'Ball'
        toy.coin_value = 5
        mock_404.return_value = toy
        profile = MagicMock()
        profile.coins = 20
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        with patch('ui.views._get_current_user', return_value=self.user), \
             patch('ui.views.StudentProfile.objects') as mp, \
             patch('ui.views.ToyRedemption.objects'), \
             patch('ui.views.transaction.atomic', return_value=ctx):
            mp.select_for_update.return_value.filter.return_value.first.return_value = profile
            req = make_req(self.f, 'post', '/student/coins/redeem/', data={'toy_id': '1'})
            r = views.student_redeem_toy(req)
        self.assertEqual(r.status_code, 200)
        self.assertIn('Ball', json.loads(r.content)['message'])
