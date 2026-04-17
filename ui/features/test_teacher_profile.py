"""Integration tests: teacher profile view."""
import pytest

from core.models import AppUser
from ui.features.conftest import login


@pytest.mark.django_db
class TestTeacherProfileGet:

    def test_unauthenticated_redirects(self, client):
        r = client.get('/teacher/profile/')
        assert r.status_code == 302

    def test_student_role_forbidden(self, client, student):
        login(client, student.id)
        r = client.get('/teacher/profile/')
        assert r.status_code == 403

    def test_teacher_sees_profile_page(self, client, teacher):
        login(client, teacher.id)
        r = client.get('/teacher/profile/')
        assert r.status_code == 200


@pytest.mark.django_db
class TestTeacherProfileUpdateNameEmail:

    def test_valid_post_updates_name_and_email(self, client, teacher):
        login(client, teacher.id)
        r = client.post('/teacher/profile/', {
            'name': 'Updated Teacher', 'email': 'updated@ui.test',
        })
        assert r.status_code == 302
        teacher.refresh_from_db()
        assert teacher.name == 'Updated Teacher'
        assert teacher.email == 'updated@ui.test'

    def test_empty_name_stays_on_form(self, client, teacher):
        login(client, teacher.id)
        r = client.post('/teacher/profile/', {
            'name': '', 'email': 'teacher@ui.test',
        })
        assert r.status_code == 200

    def test_duplicate_email_stays_on_form(self, client, teacher, student):
        login(client, teacher.id)
        r = client.post('/teacher/profile/', {
            'name': 'Teacher', 'email': 'student@ui.test',
        })
        assert r.status_code == 200


@pytest.mark.django_db
class TestTeacherProfileChangePassword:

    def test_correct_current_password_updates(self, client, teacher):
        login(client, teacher.id)
        r = client.post('/teacher/profile/', {
            'name': 'Feature Teacher', 'email': 'teacher@ui.test',
            'current_password': 'pass123',
            'new_password': 'newpass456',
            'confirm_password': 'newpass456',
        })
        assert r.status_code == 302

    def test_wrong_current_password_stays_on_form(self, client, teacher):
        login(client, teacher.id)
        r = client.post('/teacher/profile/', {
            'name': 'Feature Teacher', 'email': 'teacher@ui.test',
            'current_password': 'wrongpassword',
            'new_password': 'newpass456',
            'confirm_password': 'newpass456',
        })
        assert r.status_code == 200

    def test_mismatched_new_passwords_stays_on_form(self, client, teacher):
        login(client, teacher.id)
        r = client.post('/teacher/profile/', {
            'name': 'Feature Teacher', 'email': 'teacher@ui.test',
            'current_password': 'pass123',
            'new_password': 'newpass456',
            'confirm_password': 'different456',
        })
        assert r.status_code == 200
