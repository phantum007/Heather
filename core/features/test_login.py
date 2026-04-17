import pytest


@pytest.mark.django_db
def test_login_valid_credentials_returns_token(api, teacher):
    r = api.post('/api/login', {
        'email': teacher.email, 'password': 'pass123',
    }, format='json')
    assert r.status_code == 200
    assert 'token' in r.data
    assert r.data['user']['email'] == teacher.email


@pytest.mark.django_db
def test_login_wrong_password_returns_401(api, teacher):
    r = api.post('/api/login', {
        'email': teacher.email, 'password': 'wrongpassword',
    }, format='json')
    assert r.status_code == 401


@pytest.mark.django_db
def test_login_unknown_email_returns_401(api):
    r = api.post('/api/login', {
        'email': 'nobody@feature.test', 'password': 'pw',
    }, format='json')
    assert r.status_code == 401


@pytest.mark.django_db
def test_unauthenticated_student_endpoint_rejected(api):
    r = api.get('/api/my-assignments')
    assert r.status_code in (401, 403)


@pytest.mark.django_db
def test_unauthenticated_teacher_endpoint_rejected(api):
    r = api.get('/api/students')
    assert r.status_code in (401, 403)
