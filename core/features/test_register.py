import pytest

from core.models import AppUser, StudentProfile


@pytest.mark.django_db
def test_register_teacher_returns_201_with_token(api):
    r = api.post('/api/register', {
        'name': 'Alice', 'email': 'alice@feature.test',
        'password': 'pw123', 'role': 'teacher',
    }, format='json')
    assert r.status_code == 201
    assert 'token' in r.data
    assert r.data['user']['role'] == 'teacher'
    assert AppUser.objects.filter(email='alice@feature.test').exists()


@pytest.mark.django_db
def test_register_student_creates_profile(api, grade):
    r = api.post('/api/register', {
        'name': 'Bob', 'email': 'bob@feature.test',
        'password': 'pw123', 'role': 'student', 'gradeId': grade.id,
    }, format='json')
    assert r.status_code == 201
    assert 'token' in r.data
    user = AppUser.objects.get(email='bob@feature.test')
    assert StudentProfile.objects.filter(user=user, grade=grade).exists()


@pytest.mark.django_db
def test_register_duplicate_email_returns_400(api, teacher):
    r = api.post('/api/register', {
        'name': 'Dup', 'email': teacher.email,
        'password': 'pw123', 'role': 'teacher',
    }, format='json')
    assert r.status_code == 400


@pytest.mark.django_db
def test_register_student_without_grade_returns_400(api):
    r = api.post('/api/register', {
        'name': 'C', 'email': 'c@feature.test',
        'password': 'pw', 'role': 'student',
    }, format='json')
    assert r.status_code == 400
