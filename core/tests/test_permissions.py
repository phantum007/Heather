from unittest.mock import MagicMock

from django.test import SimpleTestCase

from core.permissions import IsAuthenticatedUser, IsStudent, IsTeacher


class PermissionsTest(SimpleTestCase):

    def _req(self, role=None):
        req = MagicMock()
        if role:
            req.user = MagicMock()
            req.user.role = role
        else:
            req.user = None
        return req

    # IsAuthenticatedUser
    def test_authenticated_user_allowed(self):
        self.assertTrue(IsAuthenticatedUser().has_permission(self._req('student'), None))

    def test_no_user_denied(self):
        self.assertFalse(IsAuthenticatedUser().has_permission(self._req(), None))

    # IsTeacher
    def test_teacher_allowed(self):
        self.assertTrue(IsTeacher().has_permission(self._req('teacher'), None))

    def test_student_denied_from_teacher(self):
        self.assertFalse(IsTeacher().has_permission(self._req('student'), None))

    def test_no_user_denied_from_teacher(self):
        self.assertFalse(IsTeacher().has_permission(self._req(), None))

    # IsStudent
    def test_student_allowed(self):
        self.assertTrue(IsStudent().has_permission(self._req('student'), None))

    def test_teacher_denied_from_student(self):
        self.assertFalse(IsStudent().has_permission(self._req('teacher'), None))

    def test_no_user_denied_from_student(self):
        self.assertFalse(IsStudent().has_permission(self._req(), None))
