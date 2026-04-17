"""Integration tests: student unit practice submit view."""
import pytest

from core.models import CurriculumUnitAttempt, StudentProfile
from ui.features.conftest import login


@pytest.mark.django_db
class TestStudentSubmitUnitValidation:

    def test_unauthenticated_redirects(self, client):
        r = client.post('/student/unit-practice/submit/', {
            'unit_id': '1', 'question_id': '1', 'assignment_id': '1', 'student_answer': '5',
        })
        assert r.status_code == 302

    def test_get_method_not_allowed(self, client, student):
        login(client, student.id)
        r = client.get('/student/unit-practice/submit/')
        assert r.status_code == 405

    def test_missing_unit_id_returns_400(self, client, student, assignment, curriculum_question):
        login(client, student.id)
        r = client.post('/student/unit-practice/submit/', {
            'question_id': str(curriculum_question.id),
            'assignment_id': str(assignment.id),
            'student_answer': '2',
        })
        assert r.status_code == 400
        assert 'required' in r.json()['message']

    def test_missing_question_id_returns_400(self, client, student, assignment, unit):
        login(client, student.id)
        r = client.post('/student/unit-practice/submit/', {
            'unit_id': str(unit.id),
            'assignment_id': str(assignment.id),
            'student_answer': '2',
        })
        assert r.status_code == 400

    def test_missing_assignment_id_returns_400(self, client, student, unit, curriculum_question):
        login(client, student.id)
        r = client.post('/student/unit-practice/submit/', {
            'unit_id': str(unit.id),
            'question_id': str(curriculum_question.id),
            'student_answer': '2',
        })
        assert r.status_code == 400

    def test_invalid_elapsed_seconds_returns_400(self, client, student, assignment, unit, curriculum_question):
        login(client, student.id)
        r = client.post('/student/unit-practice/submit/', {
            'unit_id': str(unit.id),
            'question_id': str(curriculum_question.id),
            'assignment_id': str(assignment.id),
            'student_answer': '2',
            'elapsed_seconds': 'abc',
        })
        assert r.status_code == 400

    def test_empty_answer_returns_400(self, client, student, assignment, unit, curriculum_question):
        login(client, student.id)
        r = client.post('/student/unit-practice/submit/', {
            'unit_id': str(unit.id),
            'question_id': str(curriculum_question.id),
            'assignment_id': str(assignment.id),
            'student_answer': '',
        })
        assert r.status_code == 400


@pytest.mark.django_db
class TestStudentSubmitUnitAnswer:

    def _submit(self, client, student, assignment, unit, curriculum_question, answer, elapsed='5'):
        return client.post('/student/unit-practice/submit/', {
            'unit_id': str(unit.id),
            'question_id': str(curriculum_question.id),
            'assignment_id': str(assignment.id),
            'student_answer': answer,
            'elapsed_seconds': elapsed,
        })

    def test_correct_answer_returns_200_and_is_correct_true(
        self, client, student, assignment, unit, curriculum_question
    ):
        login(client, student.id)
        r = self._submit(client, student, assignment, unit, curriculum_question, '2')
        assert r.status_code == 200
        data = r.json()
        assert data['is_correct'] is True
        assert data['status'] == 'correct'

    def test_incorrect_answer_returns_is_correct_false(
        self, client, student, assignment, unit, curriculum_question
    ):
        login(client, student.id)
        r = self._submit(client, student, assignment, unit, curriculum_question, '99')
        assert r.status_code == 200
        data = r.json()
        assert data['is_correct'] is False
        assert data['status'] == 'incorrect'

    def test_response_has_required_fields(
        self, client, student, assignment, unit, curriculum_question
    ):
        login(client, student.id)
        r = self._submit(client, student, assignment, unit, curriculum_question, '2')
        data = r.json()
        for key in ('is_correct', 'status', 'correct_count', 'wrong_count',
                    'is_complete', 'attempt_status', 'attempt_number', 'coins_awarded'):
            assert key in data

    def test_single_question_unit_completes_on_answer(
        self, client, student, assignment, unit, curriculum_question
    ):
        login(client, student.id)
        r = self._submit(client, student, assignment, unit, curriculum_question, '2')
        data = r.json()
        assert data['is_complete'] is True

    def test_correct_answer_creates_unit_attempt(
        self, client, student, assignment, unit, curriculum_question
    ):
        login(client, student.id)
        self._submit(client, student, assignment, unit, curriculum_question, '2')
        assert CurriculumUnitAttempt.objects.filter(
            student=student, unit=unit, assignment=assignment
        ).exists()

    def test_passing_unit_awards_coins(
        self, client, student, assignment, unit, curriculum_question
    ):
        profile = StudentProfile.objects.get(user=student)
        coins_before = profile.coins
        login(client, student.id)
        r = self._submit(client, student, assignment, unit, curriculum_question, '2')
        data = r.json()
        assert data['coins_awarded'] > 0
        profile.refresh_from_db()
        assert profile.coins > coins_before

    def test_duplicate_question_attempt_returns_400(
        self, client, student, assignment, unit, curriculum_question, db
    ):
        # Add a second question so the attempt stays in_progress after the first submit
        from core.models import CurriculumQuestion
        CurriculumQuestion.objects.create(unit=unit, question_text='2+2', answer_text='4', order=2)
        login(client, student.id)
        # First submit — attempt is now in_progress (1 of 2 answered)
        self._submit(client, student, assignment, unit, curriculum_question, '2')
        # Same question again in the same in-progress attempt → 400
        r = self._submit(client, student, assignment, unit, curriculum_question, '2')
        assert r.status_code == 400

    def test_unit_from_wrong_assignment_returns_400(
        self, client, teacher, student, grade, lesson, unit, curriculum_question, db
    ):
        from core.models import Assignment, LessonType
        from django.utils import timezone
        other_lesson = LessonType.objects.create(grade=grade, lesson_name='Other Lesson')
        other_assignment = Assignment.objects.create(
            teacher=teacher, student=student, lesson=other_lesson,
            assigned_date=timezone.now(), mode=Assignment.MODE_SPRINT,
        )
        login(client, student.id)
        r = client.post('/student/unit-practice/submit/', {
            'unit_id': str(unit.id),
            'question_id': str(curriculum_question.id),
            'assignment_id': str(other_assignment.id),
            'student_answer': '2',
        })
        assert r.status_code == 400
        assert 'does not belong' in r.json()['message']
