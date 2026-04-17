import pytest

from core.models import Assignment
from core.features.conftest import auth_header


@pytest.mark.django_db
def test_create_assignment_returns_201_with_questions(api, teacher, student, lesson):
    api.credentials(HTTP_AUTHORIZATION=auth_header(teacher))
    r = api.post('/api/assignments', {
        'studentId': student.id,
        'lessonId': lesson.id,
        'questions': [
            {'questionText': '3+3', 'correctAnswer': '6'},
            {'questionText': '5+5', 'correctAnswer': '10'},
        ],
    }, format='json')
    assert r.status_code == 201
    assert len(r.data['questions']) == 2
    assert Assignment.objects.filter(student=student, lesson=lesson).exists()


@pytest.mark.django_db
def test_student_cannot_create_assignment(api, student, lesson):
    api.credentials(HTTP_AUTHORIZATION=auth_header(student))
    r = api.post('/api/assignments', {
        'studentId': student.id, 'lessonId': lesson.id,
        'questions': [{'questionText': 'Q', 'correctAnswer': '1'}],
    }, format='json')
    assert r.status_code == 403


@pytest.mark.django_db
def test_create_assignment_invalid_lesson_returns_404(api, teacher, student):
    api.credentials(HTTP_AUTHORIZATION=auth_header(teacher))
    r = api.post('/api/assignments', {
        'studentId': student.id, 'lessonId': 99999,
        'questions': [{'questionText': 'Q', 'correctAnswer': '1'}],
    }, format='json')
    assert r.status_code == 404
