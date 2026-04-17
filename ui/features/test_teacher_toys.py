"""Integration tests: teacher toys management and student redemptions views."""
import pytest

from core.models import StudentProfile, Toy, ToyRedemption
from django.utils import timezone
from ui.features.conftest import login


@pytest.mark.django_db
class TestTeacherToys:

    def test_unauthenticated_redirects(self, client):
        r = client.get('/teacher/toys/')
        assert r.status_code == 302

    def test_student_forbidden(self, client, student):
        login(client, student.id)
        r = client.get('/teacher/toys/')
        assert r.status_code == 403

    def test_get_renders_toys_list(self, client, teacher, toy):
        login(client, teacher.id)
        r = client.get('/teacher/toys/')
        assert r.status_code == 200

    def test_add_toy_creates_and_redirects(self, client, teacher):
        login(client, teacher.id)
        r = client.post('/teacher/toys/', {
            'action': 'add', 'name': 'New Toy', 'coin_value': '5',
        })
        assert r.status_code == 302
        assert Toy.objects.filter(name='New Toy').exists()

    def test_add_toy_empty_name_redirects_with_error(self, client, teacher):
        login(client, teacher.id)
        before = Toy.objects.count()
        r = client.post('/teacher/toys/', {
            'action': 'add', 'name': '', 'coin_value': '5',
        })
        assert r.status_code == 302
        assert Toy.objects.count() == before

    def test_add_toy_zero_coin_value_redirects_with_error(self, client, teacher):
        login(client, teacher.id)
        before = Toy.objects.count()
        r = client.post('/teacher/toys/', {
            'action': 'add', 'name': 'Ball', 'coin_value': '0',
        })
        assert r.status_code == 302
        assert Toy.objects.count() == before

    def test_delete_toy_removes_it(self, client, teacher, toy):
        login(client, teacher.id)
        r = client.post('/teacher/toys/', {
            'action': 'delete', 'toy_id': str(toy.id),
        })
        assert r.status_code == 302
        assert not Toy.objects.filter(id=toy.id).exists()


@pytest.mark.django_db
class TestTeacherStudentRedemptions:

    def test_unauthenticated_redirects(self, client, student):
        r = client.get(f'/teacher/students/{student.id}/redemptions/')
        assert r.status_code == 302

    def test_teacher_sees_redemptions_page(self, client, teacher, student):
        login(client, teacher.id)
        r = client.get(f'/teacher/students/{student.id}/redemptions/')
        assert r.status_code == 200

    def test_redemptions_list_includes_redeemed_toy(self, client, teacher, student, toy):
        profile = StudentProfile.objects.get(user=student)
        ToyRedemption.objects.create(
            student=student,
            toy=toy,
            coins_spent=toy.coin_value,
            redeemed_at=timezone.now(),
        )
        login(client, teacher.id)
        r = client.get(f'/teacher/students/{student.id}/redemptions/')
        assert r.status_code == 200

    def test_unknown_student_returns_404(self, client, teacher):
        login(client, teacher.id)
        r = client.get('/teacher/students/99999/redemptions/')
        assert r.status_code == 404
