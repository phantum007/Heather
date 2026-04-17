"""
pytest configuration shared across all test modules.

All models in this project use managed=False (tables are managed outside Django).
The fixture below creates those tables in the test database so integration
(feature) tests can insert and query real rows.
"""
import pytest
from django.apps import apps


@pytest.fixture(scope='session')
def django_db_setup(django_db_setup, django_db_blocker):
    """Extend the default test-DB setup to create unmanaged model tables."""
    with django_db_blocker.unblock():
        from django.db import connection
        with connection.schema_editor() as editor:
            for model in apps.get_models():
                if not model._meta.managed:
                    try:
                        editor.create_model(model)
                    except Exception:
                        pass  # table already exists (e.g. re-run without --create-db)
