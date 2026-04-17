import json
from unittest.mock import MagicMock, patch

from django.test import RequestFactory, SimpleTestCase

import ui.views as views
from ui.tests.helpers import make_req, make_user


class UnitSubmitValidationTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def _post(self, data):
        req = make_req(self.f, 'post', '/student/unit-practice/submit/', data=data)
        with patch('ui.views._get_current_user', return_value=make_user()):
            return views.student_submit_unit_question(req)

    def test_missing_unit_id(self):
        r = self._post({'question_id': '1', 'assignment_id': '1', 'student_answer': '42'})
        self.assertEqual(r.status_code, 400)
        self.assertIn('required', json.loads(r.content)['message'])

    def test_missing_question_id(self):
        r = self._post({'unit_id': '1', 'assignment_id': '1', 'student_answer': '42'})
        self.assertEqual(r.status_code, 400)

    def test_missing_assignment_id(self):
        r = self._post({'unit_id': '1', 'question_id': '1', 'student_answer': '42'})
        self.assertEqual(r.status_code, 400)

    def test_invalid_elapsed_seconds(self):
        r = self._post({
            'unit_id': '1', 'question_id': '1', 'assignment_id': '1',
            'student_answer': '42', 'elapsed_seconds': 'xyz',
        })
        self.assertEqual(r.status_code, 400)

    @patch('ui.views.get_object_or_404')
    @patch('ui.views.truncate_numeric_precision', return_value='')
    def test_empty_answer_returns_400(self, _tr, mock_404):
        a = MagicMock()
        a.lesson_id = 10
        u = MagicMock()
        u.sub_lesson.lesson_type_id = 10
        mock_404.side_effect = [a, u, MagicMock()]
        r = self._post({'unit_id': '1', 'question_id': '1', 'assignment_id': '1', 'student_answer': ''})
        self.assertEqual(r.status_code, 400)

    @patch('ui.views.get_object_or_404')
    def test_wrong_lesson_returns_400(self, mock_404):
        a = MagicMock()
        a.lesson_id = 10
        u = MagicMock()
        u.sub_lesson.lesson_type_id = 99
        mock_404.side_effect = [a, u, MagicMock()]
        r = self._post({'unit_id': '1', 'question_id': '1', 'assignment_id': '1', 'student_answer': '5'})
        self.assertEqual(r.status_code, 400)
        self.assertIn('does not belong', json.loads(r.content)['message'])

    def test_get_not_allowed(self):
        req = make_req(self.f, 'get', '/student/unit-practice/submit/')
        with patch('ui.views._get_current_user', return_value=make_user()):
            r = views.student_submit_unit_question(req)
        self.assertEqual(r.status_code, 405)


class UnitSubmitResponseTest(SimpleTestCase):

    def setUp(self):
        self.f = RequestFactory()

    def _submit(self, student_answer, correct_answer, prior_status=None,
                attempt_num=1, total_questions=5):
        user = make_user()
        assignment = MagicMock()
        assignment.id = 1
        assignment.lesson_id = 10
        unit = MagicMock()
        unit.id = 1
        unit.sub_lesson.lesson_type_id = 10
        unit.curriculum_questions.count.return_value = total_questions
        question = MagicMock()
        question.id = 1
        question.answer_text = correct_answer
        is_right = (student_answer == correct_answer)
        attempt = MagicMock()
        attempt.id = 99
        attempt.attempt_number = attempt_num
        attempt.elapsed_seconds = 0
        attempt.status = 'in_progress'
        attempt.correct_count = 0
        attempt.wrong_count = 0
        attempt.question_attempts.all.return_value = [MagicMock(is_correct=is_right)]
        prior = None
        if prior_status:
            prior = MagicMock()
            prior.status = prior_status
            prior.attempt_number = attempt_num - 1
        ctx = MagicMock()
        ctx.__enter__ = lambda s: s
        ctx.__exit__ = MagicMock(return_value=False)
        req = make_req(self.f, 'post', '/student/unit-practice/submit/', data={
            'unit_id': '1', 'question_id': '1', 'assignment_id': '1',
            'student_answer': student_answer, 'elapsed_seconds': '5',
        })
        with patch('ui.views._get_current_user', return_value=user), \
             patch('ui.views.get_object_or_404', side_effect=[assignment, unit, question]), \
             patch('ui.views.CurriculumUnitAttempt.objects') as mock_att, \
             patch('ui.views.CurriculumQuestionAttempt.objects') as mock_qa, \
             patch('ui.views.StudentProfile.objects'), \
             patch('ui.views.transaction.atomic', return_value=ctx):
            mock_att.filter.return_value.order_by.return_value.first.return_value = prior
            mock_att.create.return_value = attempt
            mock_qa.get_or_create.return_value = (MagicMock(), True)
            return views.student_submit_unit_question(req)

    def test_correct_answer_shape(self):
        data = json.loads(self._submit('42', '42').content)
        for k in ('is_correct', 'status', 'correct_count', 'wrong_count',
                  'is_complete', 'attempt_status', 'attempt_number', 'coins_awarded'):
            self.assertIn(k, data)

    def test_correct_answer_is_correct_true(self):
        data = json.loads(self._submit('42', '42').content)
        self.assertTrue(data['is_correct'])
        self.assertEqual(data['status'], 'correct')

    def test_incorrect_answer_is_correct_false(self):
        data = json.loads(self._submit('99', '42').content)
        self.assertFalse(data['is_correct'])
        self.assertEqual(data['status'], 'incorrect')

    def test_retry_after_passed_creates_new_attempt(self):
        r = self._submit('42', '42', prior_status='passed', attempt_num=2)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(json.loads(r.content)['attempt_number'], 2)

    def test_retry_after_failed_creates_new_attempt(self):
        r = self._submit('5', '5', prior_status='failed', attempt_num=2)
        self.assertEqual(r.status_code, 200)
