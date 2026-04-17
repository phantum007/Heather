"""Integration tests: home, login, logout views."""
import pytest

from ui.features.conftest import login


@pytest.mark.django_db
class TestHomeRedirect:

    def test_unauthenticated_redirects_to_login(self, client):
        r = client.get('/')
        assert r.status_code == 302
        assert '/login/' in r['Location']

    def test_teacher_redirects_to_teacher_dashboard(self, client, teacher):
        login(client, teacher.id)
        r = client.get('/')
        assert r.status_code == 302
        assert 'teacher' in r['Location']

    def test_student_redirects_to_student_assignments(self, client, student):
        login(client, student.id)
        r = client.get('/')
        assert r.status_code == 302
        assert 'assignments' in r['Location']


@pytest.mark.django_db
class TestLoginView:

    def test_get_returns_200(self, client):
        r = client.get('/login/')
        assert r.status_code == 200

    def test_valid_teacher_credentials_redirect_to_teacher_dashboard(self, client, teacher):
        r = client.post('/login/', {'email': 'teacher@ui.test', 'password': 'pass123'})
        assert r.status_code == 302
        assert 'teacher' in r['Location']

    def test_valid_student_credentials_redirect_to_student_assignments(self, client, student):
        r = client.post('/login/', {'email': 'student@ui.test', 'password': 'pass123'})
        assert r.status_code == 302
        assert 'assignments' in r['Location']

    def test_wrong_password_stays_on_login(self, client, teacher):
        r = client.post('/login/', {'email': 'teacher@ui.test', 'password': 'wrong'})
        assert r.status_code == 200

    def test_unknown_email_stays_on_login(self, client):
        r = client.post('/login/', {'email': 'nobody@ui.test', 'password': 'pass'})
        assert r.status_code == 200


@pytest.mark.django_db
class TestLogoutView:

    def test_logout_clears_session_and_redirects(self, client, teacher):
        login(client, teacher.id)
        r = client.get('/logout/')
        assert r.status_code == 302
        assert '/login/' in r['Location']
        # session cleared — home now redirects to login
        r2 = client.get('/')
        assert '/login/' in r2['Location']
