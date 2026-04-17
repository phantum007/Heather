"""Shared fixtures for UI integration (feature) tests."""
import bcrypt

import pytest
from django.test import Client
from django.utils import timezone

from core.models import (
    AppUser,
    Assignment,
    CurriculumQuestion,
    Grade,
    LessonType,
    StudentProfile,
    SubLesson,
    SubLessonTypeMaster,
    Toy,
    Unit,
)

SESSION_KEY = 'ui_user_id'


def _hashed(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def login(client: Client, user_id: int) -> None:
    """Inject the user id into the session to simulate a logged-in user."""
    session = client.session
    session[SESSION_KEY] = user_id
    session.save()


@pytest.fixture
def client():
    return Client()


@pytest.fixture
def grade(db):
    return Grade.objects.create(grade_name='Grade F')


@pytest.fixture
def teacher(db):
    return AppUser.objects.create(
        name='Feature Teacher',
        email='teacher@ui.test',
        password=_hashed('pass123'),
        role='teacher',
    )


@pytest.fixture
def student(db, grade):
    user = AppUser.objects.create(
        name='Feature Student',
        email='student@ui.test',
        password=_hashed('pass123'),
        role='student',
    )
    StudentProfile.objects.create(
        user=user,
        grade=grade,
        first_name='Feature',
        last_name='Student',
        father_name='Dad',
        mother_name='Mum',
        contact='0000000000',
        coins=50,
    )
    return user


@pytest.fixture
def lesson(db, grade):
    return LessonType.objects.create(grade=grade, lesson_name='Addition')


@pytest.fixture
def sub_lesson(db, lesson):
    master = SubLessonTypeMaster.objects.create(type_name='default')
    return SubLesson.objects.create(
        lesson_type=lesson,
        sub_lesson_name='Track 1',
        sub_lesson_type_master=master,
    )


@pytest.fixture
def unit(db, sub_lesson):
    return Unit.objects.create(sub_lesson=sub_lesson, unit_name='Unit 1')


@pytest.fixture
def curriculum_question(db, unit):
    return CurriculumQuestion.objects.create(
        unit=unit, question_text='1+1', answer_text='2', order=1
    )


@pytest.fixture
def assignment(db, teacher, student, lesson):
    return Assignment.objects.create(
        teacher=teacher,
        student=student,
        lesson=lesson,
        assigned_date=timezone.now(),
        mode=Assignment.MODE_SPRINT,
    )


@pytest.fixture
def toy(db):
    return Toy.objects.create(name='Teddy Bear', coin_value=10, created_at=timezone.now())
