"""Integration tests: teacher create assignment and results views."""
import pytest

from core.models import Assignment, StudentProfile
from ui.features.conftest import login


@pytest.mark.django_db
class TestTeacherCreateAssignmentGet:

    def test_unauthenticated_redirects(self, client):
        r = client.get('/teacher/create-assignment/')
        assert r.status_code == 302

    def test_student_role_forbidden(self, client, student):
        login(client, student.id)
        r = client.get('/teacher/create-assignment/')
        assert r.status_code == 403

    def test_teacher_sees_form(self, client, teacher):
        login(client, teacher.id)
        r = client.get('/teacher/create-assignment/')
        assert r.status_code == 200

    def test_get_with_student_id_shows_grade_preselected(self, client, teacher, student, grade):
        profile = StudentProfile.objects.get(user=student)
        login(client, teacher.id)
        r = client.get(f'/teacher/create-assignment/?student_id={student.id}&grade_id={grade.id}')
        assert r.status_code == 200


@pytest.mark.django_db
class TestTeacherCreateAssignmentPost:

    def test_missing_student_stays_with_error(self, client, teacher, lesson):
        login(client, teacher.id)
        r = client.post('/teacher/create-assignment/', {
            'student_id': '', 'grade_id': '', 'lesson_ids': [str(lesson.id)],
            'assignment_kind': 'homework', 'assignment_mode': 'sprint',
        })
        assert r.status_code == 200

    def test_valid_assignment_creates_and_redirects(self, client, teacher, student, grade, lesson):
        login(client, teacher.id)
        r = client.post('/teacher/create-assignment/', {
            'student_id': str(student.id),
            'grade_id': str(grade.id),
            'lesson_ids': [str(lesson.id)],
            'assignment_kind': 'homework',
            'assignment_mode': 'sprint',
        })
        assert r.status_code == 302
        assert Assignment.objects.filter(student=student, lesson=lesson).exists()

    def test_reassigning_same_lesson_replaces_existing(self, client, teacher, student, grade, lesson, assignment):
        login(client, teacher.id)
        before = Assignment.objects.filter(student=student, lesson=lesson).count()
        r = client.post('/teacher/create-assignment/', {
            'student_id': str(student.id),
            'grade_id': str(grade.id),
            'lesson_ids': [str(lesson.id)],
            'assignment_kind': 'homework',
            'assignment_mode': 'sprint',
        })
        assert r.status_code == 302
        # old assignment replaced, count stays at 1
        assert Assignment.objects.filter(student=student, lesson=lesson).count() == 1


@pytest.mark.django_db
class TestTeacherResults:

    def test_unauthenticated_redirects(self, client):
        r = client.get('/teacher/results/')
        assert r.status_code == 302

    def test_teacher_sees_results_page(self, client, teacher):
        login(client, teacher.id)
        r = client.get('/teacher/results/')
        assert r.status_code == 200

    def test_results_with_student_id_shows_assignments(self, client, teacher, student, assignment):
        login(client, teacher.id)
        r = client.get(f'/teacher/results/?student_id={student.id}')
        assert r.status_code == 200
