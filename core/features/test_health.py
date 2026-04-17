import pytest


@pytest.mark.django_db
def test_health_returns_ok(api):
    r = api.get('/api/health/')
    assert r.status_code == 200
    assert r.data['status'] == 'ok'
    assert 'service' in r.data
