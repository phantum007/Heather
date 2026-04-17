"""Integration tests: teacher student progress, unit attempts, and reset views."""
import pytest

from core.models import CurriculumUnitAttempt, StudentProfile
from django.utils import timezone
from ui.features.conftest import login


@pytest.mark.django_db
class TestTeacherStudentProgress:

    def test_unauthenticated_redirects(self, client, student):
        r = client.get(f'/teacher/students/{student.id}/progress/')
        assert r.status_code == 302

    def test_student_role_forbidden(self, client, student):
        login(client, student.id)
        r = client.get(f'/teacher/students/{student.id}/progress/')
        assert r.status_code == 403

    def test_teacher_sees_progress_page(self, client, teacher, student):
        login(client, teacher.id)
        r = client.get(f'/teacher/students/{student.id}/progress/')
        assert r.status_code == 200

    def test_with_assignment_id_shows_tracks(self, client, teacher, student, assignment, sub_lesson):
        login(client, teacher.id)
        r = client.get(
            f'/teacher/students/{student.id}/progress/'
            f'?assignment_id={assignment.id}&track_id={sub_lesson.id}'
        )
        assert r.status_code == 200

    def test_unknown_student_returns_404(self, client, teacher):
        login(client, teacher.id)
        r = client.get('/teacher/students/99999/progress/')
        assert r.status_code == 404


@pytest.mark.django_db
class TestTeacherStudentUnitAttempts:

    def test_missing_assignment_id_returns_400(self, client, teacher, student, unit):
        login(client, teacher.id)
        r = client.get(f'/teacher/students/{student.id}/units/{unit.id}/attempts/')
        assert r.status_code == 400
        assert 'assignment_id' in r.json()['message']

    def test_returns_attempts_list(self, client, teacher, student, assignment, unit):
        login(client, teacher.id)
        r = client.get(
            f'/teacher/students/{student.id}/units/{unit.id}/attempts/'
            f'?assignment_id={assignment.id}'
        )
        assert r.status_code == 200
        data = r.json()
        assert data['unit_id'] == unit.id
        assert 'attempts' in data

    def test_unauthenticated_redirects(self, client, student, unit):
        r = client.get(f'/teacher/students/{student.id}/units/{unit.id}/attempts/?assignment_id=1')
        assert r.status_code == 302


@pytest.mark.django_db
class TestTeacherResetStudentUnit:

    def test_missing_assignment_id_returns_400(self, client, teacher, student, unit):
        login(client, teacher.id)
        r = client.post(f'/teacher/students/{student.id}/units/{unit.id}/reset/')
        assert r.status_code == 400

    def test_reset_deletes_attempts_and_returns_json(self, client, teacher, student, assignment, unit):
        CurriculumUnitAttempt.objects.create(
            student=student,
            unit=unit,
            assignment=assignment,
            attempt_number=1,
            status=CurriculumUnitAttempt.STATUS_IN_PROGRESS,
            elapsed_seconds=10,
            correct_count=0,
            wrong_count=0,
            created_at=timezone.now(),
            updated_at=timezone.now(),
        )
        login(client, teacher.id)
        r = client.post(
            f'/teacher/students/{student.id}/units/{unit.id}/reset/',
            {'assignment_id': str(assignment.id)},
        )
        assert r.status_code == 200
        data = r.json()
        assert data['deleted'] == 1
        assert CurriculumUnitAttempt.objects.filter(student=student, unit=unit).count() == 0

    def test_get_method_not_allowed(self, client, teacher, student, unit, assignment):
        login(client, teacher.id)
        r = client.get(
            f'/teacher/students/{student.id}/units/{unit.id}/reset/'
            f'?assignment_id={assignment.id}'
        )
        assert r.status_code == 405
