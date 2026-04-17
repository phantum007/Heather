"""Shared fixtures for core integration (feature) tests."""
import bcrypt

import pytest
from django.utils import timezone
from rest_framework.test import APIClient

from core.models import AppUser, Assignment, Grade, LessonType, Question, StudentProfile
from core.serializers import build_token


def _hashed(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


@pytest.fixture
def api():
    return APIClient()


@pytest.fixture
def grade(db):
    return Grade.objects.create(grade_name='Test Grade')


@pytest.fixture
def teacher(db):
    return AppUser.objects.create(
        name='Teacher One',
        email='teacher@feature.test',
        password=_hashed('pass123'),
        role='teacher',
    )


@pytest.fixture
def student(db, grade):
    user = AppUser.objects.create(
        name='Student One',
        email='student@feature.test',
        password=_hashed('pass123'),
        role='student',
    )
    StudentProfile.objects.create(user=user, grade=grade)
    return user


@pytest.fixture
def lesson(db, grade):
    return LessonType.objects.create(grade=grade, lesson_name='Addition')


@pytest.fixture
def assignment(db, teacher, student, lesson):
    asgn = Assignment.objects.create(
        teacher=teacher,
        student=student,
        lesson=lesson,
        assigned_date=timezone.now(),
    )
    Question.objects.create(
        assignment=asgn, question_text='1+1', correct_answer='2', order=1
    )
    Question.objects.create(
        assignment=asgn, question_text='2+2', correct_answer='4', order=2
    )
    return asgn


def auth_header(user) -> str:
    return f'Bearer {build_token(user)}'
