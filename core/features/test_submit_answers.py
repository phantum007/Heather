import pytest

from core.models import StudentAnswer
from core.features.conftest import auth_header


@pytest.mark.django_db
def test_submit_all_correct_scores_100_percent(api, student, assignment):
    questions = list(assignment.questions.order_by('order'))
    api.credentials(HTTP_AUTHORIZATION=auth_header(student))
    r = api.post('/api/submit-answers', {
        'answers': [
            {'questionId': questions[0].id, 'studentAnswer': '2'},
            {'questionId': questions[1].id, 'studentAnswer': '4'},
        ],
    }, format='json')
    assert r.status_code == 200
    assert r.data['correct'] == 2
    assert r.data['total'] == 2
    assert r.data['percentage'] == 100


@pytest.mark.django_db
def test_submit_all_wrong_scores_zero(api, student, assignment):
    questions = list(assignment.questions.order_by('order'))
    api.credentials(HTTP_AUTHORIZATION=auth_header(student))
    r = api.post('/api/submit-answers', {
        'answers': [
            {'questionId': questions[0].id, 'studentAnswer': '99'},
            {'questionId': questions[1].id, 'studentAnswer': '99'},
        ],
    }, format='json')
    assert r.status_code == 200
    assert r.data['correct'] == 0
    assert r.data['percentage'] == 0


@pytest.mark.django_db
def test_submit_persists_answers_to_db(api, student, assignment):
    question = assignment.questions.order_by('order').first()
    api.credentials(HTTP_AUTHORIZATION=auth_header(student))
    api.post('/api/submit-answers', {
        'answers': [{'questionId': question.id, 'studentAnswer': '2'}],
    }, format='json')
    saved = StudentAnswer.objects.get(question=question, student=student)
    assert saved.student_answer == '2'
    assert saved.is_correct is True


@pytest.mark.django_db
def test_teacher_cannot_submit_answers(api, teacher, assignment):
    question = assignment.questions.first()
    api.credentials(HTTP_AUTHORIZATION=auth_header(teacher))
    r = api.post('/api/submit-answers', {
        'answers': [{'questionId': question.id, 'studentAnswer': '2'}],
    }, format='json')
    assert r.status_code == 403
