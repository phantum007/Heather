from unittest.mock import MagicMock, patch

from django.test import SimpleTestCase

import core.views as api_views
from core.tests.helpers import api_req, make_user


class SubmitAnswersViewTest(SimpleTestCase):

    def test_missing_answers_returns_400(self):
        user = make_user(role='student')
        req = api_req('post', '/api/submit-answers/', data={}, user=user)
        with patch('core.views.IsStudent.has_permission', return_value=True), \
             patch('core.views.IsAuthenticatedUser.has_permission', return_value=True):
            r = api_views.SubmitAnswersView.as_view()(req)
        self.assertEqual(r.status_code, 400)

    def test_answer_missing_question_id_returns_400(self):
        user = make_user(role='student')
        req = api_req('post', '/api/submit-answers/', data={
            'answers': [{'studentAnswer': '5'}],
        }, user=user)
        with patch('core.views.IsStudent.has_permission', return_value=True), \
             patch('core.views.IsAuthenticatedUser.has_permission', return_value=True):
            r = api_views.SubmitAnswersView.as_view()(req)
        self.assertEqual(r.status_code, 400)

    def test_question_not_found_returns_400(self):
        user = make_user(role='student')
        req = api_req('post', '/api/submit-answers/', data={
            'answers': [{'questionId': 999, 'studentAnswer': '5'}],
        }, user=user)
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        with patch('core.views.IsStudent.has_permission', return_value=True), \
             patch('core.views.IsAuthenticatedUser.has_permission', return_value=True), \
             patch('core.views.Question.objects') as mq, \
             patch('core.views.transaction.atomic', return_value=ctx):
            from core.models import Question
            mq.get.side_effect = Question.DoesNotExist
            r = api_views.SubmitAnswersView.as_view()(req)
        self.assertEqual(r.status_code, 400)

    def test_valid_answers_returns_200(self):
        user = make_user(role='student')
        user.id = 1
        req = api_req('post', '/api/submit-answers/', data={
            'answers': [{'questionId': 1, 'studentAnswer': '42'}],
        }, user=user)
        question = MagicMock()
        question.id = 1
        question.correct_answer = '42'
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        with patch('core.views.IsStudent.has_permission', return_value=True), \
             patch('core.views.IsAuthenticatedUser.has_permission', return_value=True), \
             patch('core.views.Question.objects') as mq, \
             patch('core.views.StudentAnswer.objects'), \
             patch('core.views.transaction.atomic', return_value=ctx):
            mq.get.return_value = question
            r = api_views.SubmitAnswersView.as_view()(req)
        self.assertEqual(r.status_code, 200)
        self.assertIn('correct', r.data)
        self.assertIn('total', r.data)
        self.assertIn('percentage', r.data)
