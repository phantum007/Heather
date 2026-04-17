import pytest

from core.features.conftest import auth_header


@pytest.mark.django_db
def test_my_assignments_returns_assigned_work(api, student, assignment):
    api.credentials(HTTP_AUTHORIZATION=auth_header(student))
    r = api.get('/api/my-assignments')
    assert r.status_code == 200
    assert len(r.data) == 1
    assert r.data[0]['assignment_id'] == assignment.id
    assert len(r.data[0]['questions']) == 2


@pytest.mark.django_db
def test_my_assignments_empty_for_new_student(api, student):
    api.credentials(HTTP_AUTHORIZATION=auth_header(student))
    r = api.get('/api/my-assignments')
    assert r.status_code == 200
    assert r.data == []


@pytest.mark.django_db
def test_my_assignments_teacher_forbidden(api, teacher):
    api.credentials(HTTP_AUTHORIZATION=auth_header(teacher))
    r = api.get('/api/my-assignments')
    assert r.status_code == 403
