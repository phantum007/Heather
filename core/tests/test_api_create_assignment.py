from unittest.mock import patch

from django.test import SimpleTestCase

import core.views as api_views
from core.tests.helpers import api_req, make_user


class CreateAssignmentViewTest(SimpleTestCase):

    def test_missing_fields_returns_400(self):
        user = make_user(role='teacher')
        req = api_req('post', '/api/create-assignment/', data={}, user=user)
        with patch('core.views.IsTeacher.has_permission', return_value=True), \
             patch('core.views.IsAuthenticatedUser.has_permission', return_value=True):
            r = api_views.CreateAssignmentView.as_view()(req)
        self.assertEqual(r.status_code, 400)

    def test_question_missing_answer_returns_400(self):
        user = make_user(role='teacher')
        req = api_req('post', '/api/create-assignment/', data={
            'studentId': 1, 'lessonId': 1,
            'questions': [{'questionText': 'Q1', 'correctAnswer': ''}],
        }, user=user)
        with patch('core.views.IsTeacher.has_permission', return_value=True), \
             patch('core.views.IsAuthenticatedUser.has_permission', return_value=True):
            r = api_views.CreateAssignmentView.as_view()(req)
        self.assertEqual(r.status_code, 400)

    def test_lesson_not_found_returns_404(self):
        user = make_user(role='teacher')
        req = api_req('post', '/api/create-assignment/', data={
            'studentId': 1, 'lessonId': 999,
            'questions': [{'questionText': 'Q1', 'correctAnswer': '42'}],
        }, user=user)
        with patch('core.views.IsTeacher.has_permission', return_value=True), \
             patch('core.views.IsAuthenticatedUser.has_permission', return_value=True), \
             patch('core.views.LessonType.objects') as ml:
            from core.models import LessonType
            ml.select_related.return_value.get.side_effect = LessonType.DoesNotExist
            r = api_views.CreateAssignmentView.as_view()(req)
        self.assertEqual(r.status_code, 404)
