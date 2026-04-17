"""Integration tests: student profile view."""
import pytest

from core.models import AppUser, StudentProfile
from ui.features.conftest import login


@pytest.mark.django_db
class TestStudentProfileGet:

    def test_unauthenticated_redirects(self, client):
        r = client.get('/student/profile/')
        assert r.status_code == 302

    def test_teacher_role_forbidden(self, client, teacher):
        login(client, teacher.id)
        r = client.get('/student/profile/')
        assert r.status_code == 403

    def test_student_sees_profile(self, client, student):
        login(client, student.id)
        r = client.get('/student/profile/')
        assert r.status_code == 200

    def test_edit_mode_via_query_param(self, client, student):
        login(client, student.id)
        r = client.get('/student/profile/?edit=1')
        assert r.status_code == 200


@pytest.mark.django_db
class TestStudentProfileUpdate:

    def test_valid_post_updates_profile(self, client, student):
        login(client, student.id)
        r = client.post('/student/profile/', {
            'first_name': 'Updated', 'last_name': 'Student',
            'father_name': 'Dad', 'mother_name': 'Mum',
            'email': 'student@ui.test', 'contact': '9999999999',
        })
        assert r.status_code == 302
        profile = StudentProfile.objects.get(user=student)
        assert profile.first_name == 'Updated'
        assert profile.contact == '9999999999'

    def test_missing_required_fields_stays_on_form(self, client, student):
        login(client, student.id)
        r = client.post('/student/profile/', {
            'first_name': '', 'last_name': 'Student',
            'father_name': 'Dad', 'mother_name': 'Mum',
            'email': 'student@ui.test', 'contact': '9999999999',
        })
        assert r.status_code == 200

    def test_duplicate_email_stays_on_form(self, client, student, teacher):
        login(client, student.id)
        r = client.post('/student/profile/', {
            'first_name': 'Feature', 'last_name': 'Student',
            'father_name': 'Dad', 'mother_name': 'Mum',
            'email': 'teacher@ui.test',  # teacher's email
            'contact': '9999999999',
        })
        assert r.status_code == 200


@pytest.mark.django_db
class TestStudentProfileChangePassword:

    def test_correct_current_password_updates(self, client, student):
        login(client, student.id)
        r = client.post('/student/profile/', {
            'first_name': 'Feature', 'last_name': 'Student',
            'father_name': 'Dad', 'mother_name': 'Mum',
            'email': 'student@ui.test', 'contact': '0000000000',
            'current_password': 'pass123',
            'new_password': 'newpass789',
            'confirm_password': 'newpass789',
        })
        assert r.status_code == 302

    def test_wrong_current_password_stays_on_form(self, client, student):
        login(client, student.id)
        r = client.post('/student/profile/', {
            'first_name': 'Feature', 'last_name': 'Student',
            'father_name': 'Dad', 'mother_name': 'Mum',
            'email': 'student@ui.test', 'contact': '0000000000',
            'current_password': 'wrongpassword',
            'new_password': 'newpass789',
            'confirm_password': 'newpass789',
        })
        assert r.status_code == 200

    def test_mismatched_passwords_stays_on_form(self, client, student):
        login(client, student.id)
        r = client.post('/student/profile/', {
            'first_name': 'Feature', 'last_name': 'Student',
            'father_name': 'Dad', 'mother_name': 'Mum',
            'email': 'student@ui.test', 'contact': '0000000000',
            'current_password': 'pass123',
            'new_password': 'newpass789',
            'confirm_password': 'different789',
        })
        assert r.status_code == 200
