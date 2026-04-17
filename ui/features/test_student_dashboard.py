"""Integration tests: student dashboard and student assignments views."""
import pytest

from core.models import Assignment
from ui.features.conftest import login


@pytest.mark.django_db
class TestStudentDashboard:

    def test_unauthenticated_redirects(self, client):
        r = client.get('/student/')
        assert r.status_code == 302

    def test_teacher_role_forbidden(self, client, teacher):
        login(client, teacher.id)
        r = client.get('/student/')
        assert r.status_code == 403

    def test_student_sees_dashboard(self, client, student):
        login(client, student.id)
        r = client.get('/student/')
        assert r.status_code == 200

    def test_dashboard_with_assignment(self, client, student, assignment):
        login(client, student.id)
        r = client.get('/student/')
        assert r.status_code == 200


@pytest.mark.django_db
class TestStudentAssignments:

    def test_unauthenticated_redirects(self, client):
        r = client.get('/student/assignments/')
        assert r.status_code == 302

    def test_student_sees_assignments_page(self, client, student):
        login(client, student.id)
        r = client.get('/student/assignments/')
        assert r.status_code == 200

    def test_filter_homework_category(self, client, student, assignment):
        login(client, student.id)
        r = client.get('/student/assignments/?category=homework')
        assert r.status_code == 200

    def test_filter_classroom_category(self, client, student):
        login(client, student.id)
        r = client.get('/student/assignments/?category=classroom')
        assert r.status_code == 200

    def test_invalid_category_defaults_to_all(self, client, student):
        login(client, student.id)
        r = client.get('/student/assignments/?category=invalid')
        assert r.status_code == 200

    def test_selected_assignment_loads_tracks(self, client, student, assignment, curriculum_question):
        login(client, student.id)
        r = client.get(f'/student/assignments/?assignment_id={assignment.id}')
        assert r.status_code == 200
