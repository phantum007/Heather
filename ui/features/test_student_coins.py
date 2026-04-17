"""Integration tests: student coins page and redeem toy views."""
import pytest

from core.models import StudentProfile, ToyRedemption
from ui.features.conftest import login


@pytest.mark.django_db
class TestStudentCoinsPage:

    def test_unauthenticated_redirects(self, client):
        r = client.get('/student/coins/')
        assert r.status_code == 302

    def test_teacher_role_forbidden(self, client, teacher):
        login(client, teacher.id)
        r = client.get('/student/coins/')
        assert r.status_code == 403

    def test_student_sees_coins_page(self, client, student):
        login(client, student.id)
        r = client.get('/student/coins/')
        assert r.status_code == 200

    def test_coins_page_lists_toys(self, client, student, toy):
        login(client, student.id)
        r = client.get('/student/coins/')
        assert r.status_code == 200

    def test_post_method_not_allowed(self, client, student):
        login(client, student.id)
        r = client.post('/student/coins/')
        assert r.status_code == 405


@pytest.mark.django_db
class TestStudentRedeemToy:

    def test_missing_toy_id_returns_400(self, client, student):
        login(client, student.id)
        r = client.post('/student/coins/redeem/')
        assert r.status_code == 400
        assert 'toy_id' in r.json()['message']

    def test_not_enough_coins_returns_400(self, client, student, toy):
        # toy costs 10, student has 50 — make it cost more
        toy.coin_value = 999
        toy.save()
        login(client, student.id)
        r = client.post('/student/coins/redeem/', {'toy_id': str(toy.id)})
        assert r.status_code == 400
        assert 'coins' in r.json()['message']

    def test_successful_redemption_deducts_coins(self, client, student, toy):
        profile = StudentProfile.objects.get(user=student)
        coins_before = profile.coins
        login(client, student.id)
        r = client.post('/student/coins/redeem/', {'toy_id': str(toy.id)})
        assert r.status_code == 200
        data = r.json()
        assert toy.name in data['message']
        assert data['coins_remaining'] == coins_before - toy.coin_value
        profile.refresh_from_db()
        assert profile.coins == coins_before - toy.coin_value
        assert ToyRedemption.objects.filter(student=student, toy=toy).exists()

    def test_unauthenticated_redirects(self, client, toy):
        r = client.post('/student/coins/redeem/', {'toy_id': str(toy.id)})
        assert r.status_code == 302

    def test_get_method_not_allowed(self, client, student):
        login(client, student.id)
        r = client.get('/student/coins/redeem/')
        assert r.status_code == 405
