"""Integration tests: teacher students CRUD views."""
import pytest

from core.models import AppUser, StudentProfile
from ui.features.conftest import login


@pytest.mark.django_db
class TestTeacherStudentsList:

    def test_unauthenticated_redirects(self, client):
        r = client.get('/teacher/students/')
        assert r.status_code == 302

    def test_student_role_forbidden(self, client, student):
        login(client, student.id)
        r = client.get('/teacher/students/')
        assert r.status_code == 403

    def test_teacher_sees_students_page(self, client, teacher):
        login(client, teacher.id)
        r = client.get('/teacher/students/')
        assert r.status_code == 200


@pytest.mark.django_db
class TestTeacherAddStudent:

    def test_get_renders_form(self, client, teacher, grade):
        login(client, teacher.id)
        r = client.get('/teacher/students/add/')
        assert r.status_code == 200

    def test_missing_required_fields_stays_on_form(self, client, teacher, grade):
        login(client, teacher.id)
        r = client.post('/teacher/students/add/', {
            'first_name': '', 'last_name': 'Doe',
            'father_name': 'Dad', 'mother_name': 'Mum',
            'email': 'new@test.com', 'contact': '1234567890',
            'password': 'pass', 'grade_id': str(grade.id),
        })
        assert r.status_code == 200

    def test_duplicate_email_stays_on_form(self, client, teacher, student, grade):
        login(client, teacher.id)
        r = client.post('/teacher/students/add/', {
            'first_name': 'Jane', 'last_name': 'Doe',
            'father_name': 'Dad', 'mother_name': 'Mum',
            'email': 'student@ui.test',  # already exists
            'contact': '1234567890',
            'password': 'pass', 'grade_id': str(grade.id),
        })
        assert r.status_code == 200

    def test_valid_data_creates_student_and_redirects(self, client, teacher, grade):
        login(client, teacher.id)
        r = client.post('/teacher/students/add/', {
            'first_name': 'New', 'last_name': 'Student',
            'father_name': 'Dad', 'mother_name': 'Mum',
            'email': 'newstudent@ui.test',
            'contact': '9876543210',
            'password': 'testpass123', 'grade_id': str(grade.id),
        })
        assert r.status_code == 302
        assert AppUser.objects.filter(email='newstudent@ui.test').exists()


@pytest.mark.django_db
class TestTeacherEditStudent:

    def test_get_renders_form(self, client, teacher, student, grade):
        profile = StudentProfile.objects.get(user=student)
        login(client, teacher.id)
        r = client.get(f'/teacher/students/{profile.id}/edit/')
        assert r.status_code == 200

    def test_valid_post_updates_and_redirects(self, client, teacher, student, grade):
        profile = StudentProfile.objects.get(user=student)
        login(client, teacher.id)
        r = client.post(f'/teacher/students/{profile.id}/edit/', {
            'first_name': 'Updated', 'last_name': 'Name',
            'father_name': 'Dad', 'mother_name': 'Mum',
            'email': 'student@ui.test',
            'contact': '1111111111',
            'grade_id': str(grade.id),
        })
        assert r.status_code == 302
        profile.refresh_from_db()
        assert profile.first_name == 'Updated'

    def test_missing_required_fields_stays_on_form(self, client, teacher, student, grade):
        profile = StudentProfile.objects.get(user=student)
        login(client, teacher.id)
        r = client.post(f'/teacher/students/{profile.id}/edit/', {
            'first_name': '', 'last_name': 'Name',
            'father_name': 'Dad', 'mother_name': 'Mum',
            'email': 'student@ui.test', 'contact': '1111111111',
        })
        assert r.status_code == 200


@pytest.mark.django_db
class TestTeacherDeleteStudent:

    def test_delete_removes_student_and_redirects(self, client, teacher, grade):
        from core.models import AppUser, StudentProfile
        import bcrypt
        user = AppUser.objects.create(
            name='To Delete', email='todelete@ui.test',
            password=bcrypt.hashpw(b'pass', bcrypt.gensalt()).decode(),
            role='student',
        )
        profile = StudentProfile.objects.create(
            user=user, grade=grade, first_name='To', last_name='Delete',
            father_name='Dad', mother_name='Mum', contact='0000000001',
        )
        login(client, teacher.id)
        r = client.post(f'/teacher/students/{profile.id}/delete/')
        assert r.status_code == 302
        assert not AppUser.objects.filter(id=user.id).exists()
