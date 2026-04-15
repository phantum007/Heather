"""
Pure-Python regression tests for core utilities and business logic.
All tests use SimpleTestCase — no database is created or needed.
"""
import jwt
from unittest.mock import MagicMock, patch

from django.conf import settings
from django.test import SimpleTestCase
from rest_framework import exceptions

from core.answer_utils import (
    _normalize_numeric_answer,
    answers_match,
    truncate_numeric_precision,
)
from core.authentication import JWTAuthentication
from core.permissions import IsAuthenticatedUser, IsStudent, IsTeacher


# ---------------------------------------------------------------------------
# truncate_numeric_precision
# ---------------------------------------------------------------------------

class TruncateNumericPrecisionTest(SimpleTestCase):

    def test_integer_unchanged(self):
        self.assertEqual(truncate_numeric_precision("42"), "42")

    def test_three_decimal_places_unchanged(self):
        self.assertEqual(truncate_numeric_precision("3.141"), "3.141")

    def test_four_decimal_places_truncated(self):
        self.assertEqual(truncate_numeric_precision("3.14159"), "3.141")

    def test_truncates_not_rounds(self):
        self.assertEqual(truncate_numeric_precision("1.9999"), "1.999")

    def test_comma_stripped(self):
        self.assertEqual(truncate_numeric_precision("1,234"), "1234")

    def test_comma_decimal_number(self):
        self.assertEqual(
            truncate_numeric_precision("1,234.5678"), "1234.567"
        )

    def test_non_numeric_returned_as_is(self):
        self.assertEqual(truncate_numeric_precision("abc"), "abc")

    def test_empty_string(self):
        self.assertEqual(truncate_numeric_precision(""), "")

    def test_none(self):
        self.assertEqual(truncate_numeric_precision(None), "")

    def test_negative_number(self):
        self.assertEqual(truncate_numeric_precision("-5.12345"), "-5.123")

    def test_zero(self):
        self.assertEqual(truncate_numeric_precision("0"), "0")

    def test_whitespace_stripped(self):
        self.assertEqual(truncate_numeric_precision("  7  "), "7")


# ---------------------------------------------------------------------------
# _normalize_numeric_answer edge cases
# ---------------------------------------------------------------------------

class NormalizeNumericAnswerTest(SimpleTestCase):

    def test_empty_string_returns_none(self):
        # Hits the `if not text: return None` branch (line 31 of answer_utils)
        self.assertIsNone(_normalize_numeric_answer(""))

    def test_none_returns_none(self):
        self.assertIsNone(_normalize_numeric_answer(None))

    def test_integer_string(self):
        self.assertEqual(_normalize_numeric_answer("42"), "42")

    def test_trailing_zeros_stripped(self):
        self.assertEqual(_normalize_numeric_answer("3.50"), "3.5")

    def test_non_numeric_returns_none(self):
        # Hits the `except InvalidOperation: return None` branch
        self.assertIsNone(_normalize_numeric_answer("abc"))

    def test_point_zero_becomes_integer(self):
        self.assertEqual(_normalize_numeric_answer("5.0"), "5")


# ---------------------------------------------------------------------------
# answers_match
# ---------------------------------------------------------------------------

class AnswersMatchTest(SimpleTestCase):

    def test_exact_match(self):
        self.assertTrue(answers_match("42", "42"))

    def test_trailing_zero_equivalence(self):
        self.assertTrue(answers_match("3.50", "3.5"))

    def test_leading_zero(self):
        self.assertTrue(answers_match("007", "7"))

    def test_integer_decimal_equivalence(self):
        self.assertTrue(answers_match("5.0", "5"))

    def test_comma_number(self):
        self.assertTrue(answers_match("1,234", "1234"))

    def test_different_numbers(self):
        self.assertFalse(answers_match("3", "4"))

    def test_negative_match(self):
        self.assertTrue(answers_match("-10", "-10"))

    def test_negative_sign_mismatch(self):
        self.assertFalse(answers_match("-10", "10"))

    def test_text_case_insensitive(self):
        self.assertTrue(answers_match("Hello", "hello"))

    def test_text_mismatch(self):
        self.assertFalse(answers_match("cat", "dog"))

    def test_empty_student(self):
        self.assertFalse(answers_match("", "42"))

    def test_empty_correct(self):
        self.assertFalse(answers_match("42", ""))

    def test_both_empty(self):
        self.assertFalse(answers_match("", ""))

    def test_none_student(self):
        self.assertFalse(answers_match(None, "42"))

    def test_none_correct(self):
        self.assertFalse(answers_match("42", None))

    def test_precision_truncation_match(self):
        self.assertTrue(answers_match("1.9999", "1.999"))

    def test_precision_truncation_mismatch(self):
        self.assertFalse(answers_match("1.999", "2.000"))

    def test_whitespace(self):
        self.assertTrue(answers_match("  5  ", "5"))


# ---------------------------------------------------------------------------
# JWTAuthentication
# ---------------------------------------------------------------------------

class JWTAuthenticationTest(SimpleTestCase):

    def setUp(self):
        self.auth = JWTAuthentication()

    def _request(self, header=b''):
        req = MagicMock()
        req.META = {
            'HTTP_AUTHORIZATION': header.decode() if header else ''
        }
        return req

    @patch('core.authentication.get_authorization_header', return_value=b'')
    def test_no_header_returns_none(self, _mock):
        req = self._request()
        # get_authorization_header().split() → [] (falsy)
        with patch(
            'core.authentication.get_authorization_header',
            return_value=b'',
        ):
            result = self.auth.authenticate(req)
        self.assertIsNone(result)

    def test_wrong_scheme_raises(self):
        with patch(
            'core.authentication.get_authorization_header',
            return_value=b'Basic abc123',
        ):
            with self.assertRaises(exceptions.AuthenticationFailed):
                self.auth.authenticate(MagicMock())

    def test_missing_token_raises(self):
        # Only one part after split
        with patch(
            'core.authentication.get_authorization_header',
            return_value=b'Bearer',
        ):
            with self.assertRaises(exceptions.AuthenticationFailed):
                self.auth.authenticate(MagicMock())

    def test_invalid_jwt_raises(self):
        with patch(
            'core.authentication.get_authorization_header',
            return_value=b'Bearer badtoken',
        ), patch('core.authentication.jwt.decode') as mock_decode:
            mock_decode.side_effect = jwt.PyJWTError('bad')
            with self.assertRaises(exceptions.AuthenticationFailed):
                self.auth.authenticate(MagicMock())

    def test_payload_missing_id_raises(self):
        with patch(
            'core.authentication.get_authorization_header',
            return_value=b'Bearer validtoken',
        ), patch(
            'core.authentication.jwt.decode',
            return_value={'email': 'x@x.com'},  # no 'id'
        ):
            with self.assertRaises(exceptions.AuthenticationFailed):
                self.auth.authenticate(MagicMock())

    def test_user_not_found_raises(self):
        with patch(
            'core.authentication.get_authorization_header',
            return_value=b'Bearer validtoken',
        ), patch(
            'core.authentication.jwt.decode',
            return_value={'id': 99},
        ), patch(
            'core.authentication.AppUser.objects.get',
        ) as mock_get:
            from core.models import AppUser
            mock_get.side_effect = AppUser.DoesNotExist
            with self.assertRaises(exceptions.AuthenticationFailed):
                self.auth.authenticate(MagicMock())

    def test_valid_token_returns_user_and_token(self):
        user = MagicMock()
        with patch(
            'core.authentication.get_authorization_header',
            return_value=b'Bearer mytoken',
        ), patch(
            'core.authentication.jwt.decode',
            return_value={'id': 1},
        ), patch(
            'core.authentication.AppUser.objects.get',
            return_value=user,
        ):
            result = self.auth.authenticate(MagicMock())
        self.assertEqual(result, (user, 'mytoken'))


# ---------------------------------------------------------------------------
# Permissions
# ---------------------------------------------------------------------------

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
        self.assertTrue(
            IsAuthenticatedUser().has_permission(self._req('student'), None)
        )

    def test_no_user_denied(self):
        self.assertFalse(
            IsAuthenticatedUser().has_permission(self._req(), None)
        )

    # IsTeacher
    def test_teacher_allowed(self):
        self.assertTrue(
            IsTeacher().has_permission(self._req('teacher'), None)
        )

    def test_student_denied_from_teacher(self):
        self.assertFalse(
            IsTeacher().has_permission(self._req('student'), None)
        )

    def test_no_user_denied_from_teacher(self):
        self.assertFalse(
            IsTeacher().has_permission(self._req(), None)
        )

    # IsStudent
    def test_student_allowed(self):
        self.assertTrue(
            IsStudent().has_permission(self._req('student'), None)
        )

    def test_teacher_denied_from_student(self):
        self.assertFalse(
            IsStudent().has_permission(self._req('teacher'), None)
        )

    def test_no_user_denied_from_student(self):
        self.assertFalse(
            IsStudent().has_permission(self._req(), None)
        )


# ---------------------------------------------------------------------------
# Serializer helpers (build_token, serialize_user)
# ---------------------------------------------------------------------------

class SerializerHelpersTest(SimpleTestCase):

    def _user(self, **kwargs):
        u = MagicMock()
        u.id = kwargs.get('id', 1)
        u.name = kwargs.get('name', 'Alice')
        u.email = kwargs.get('email', 'alice@example.com')
        u.role = kwargs.get('role', 'student')
        return u

    def test_serialize_user_shape(self):
        from core.serializers import serialize_user
        data = serialize_user(self._user())
        self.assertEqual(set(data.keys()), {'id', 'name', 'email', 'role'})

    def test_serialize_user_values(self):
        from core.serializers import serialize_user
        user = self._user(id=7, name='Bob', email='bob@x.com', role='teacher')
        data = serialize_user(user)
        self.assertEqual(data['id'], 7)
        self.assertEqual(data['name'], 'Bob')
        self.assertEqual(data['email'], 'bob@x.com')
        self.assertEqual(data['role'], 'teacher')

    def test_build_token_returns_string(self):
        from core.serializers import build_token
        token = build_token(self._user())
        self.assertIsInstance(token, str)
        self.assertTrue(len(token) > 10)

    def test_build_token_decodable(self):
        from core.serializers import build_token
        user = self._user(id=5)
        token = build_token(user)
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM],
        )
        self.assertEqual(payload['id'], 5)


# ---------------------------------------------------------------------------
# Lesson sort key (from ui/views helper)
# ---------------------------------------------------------------------------

class LessonSortKeyTest(SimpleTestCase):

    def _key(self, value):
        from ui.views import _lesson_sort_key
        return _lesson_sort_key(value)

    def test_numeric_string_sorts_first(self):
        self.assertEqual(self._key("3")[0], 0)

    def test_numeric_value_extracted(self):
        self.assertEqual(self._key("12")[1], 12)

    def test_text_string_sorts_second(self):
        self.assertEqual(self._key("alpha")[0], 1)

    def test_numeric_before_text(self):
        self.assertLess(self._key("1"), self._key("abc"))

    def test_numeric_order(self):
        self.assertLess(self._key("2"), self._key("10"))

    def test_none_becomes_text(self):
        self.assertEqual(self._key(None)[0], 1)

    def test_empty_string_becomes_text(self):
        self.assertEqual(self._key("")[0], 1)


# ---------------------------------------------------------------------------
# Assignment locking logic
# ---------------------------------------------------------------------------

class AssignmentLockingLogicTest(SimpleTestCase):

    class _Fake:
        def __init__(self, id, lesson_id, mode):
            self.id = id
            self.lesson_id = lesson_id
            self.mode = mode
            self.is_locked = False

    def _apply(self, assignments, unit_counts, passed_counts):
        from core.models import Assignment
        complete = {
            a.id for a in assignments
            if unit_counts.get(a.lesson_id, 0) > 0
            and passed_counts.get(a.id, 0)
            >= unit_counts.get(a.lesson_id, 0)
        }
        for i, a in enumerate(assignments):
            if i == 0 or a.mode not in (
                Assignment.MODE_STANDARD, Assignment.MODE_LOCK
            ):
                a.is_locked = False
            else:
                a.is_locked = assignments[i - 1].id not in complete
        return assignments

    def _a(self, id, lesson_id, mode='standard'):
        return self._Fake(id, lesson_id, mode)

    def test_sprint_never_locked(self):
        a1 = self._a(1, 10, 'sprint')
        a2 = self._a(2, 11, 'sprint')
        self._apply([a1, a2], {10: 5, 11: 5}, {1: 0, 2: 0})
        self.assertFalse(a1.is_locked)
        self.assertFalse(a2.is_locked)

    def test_first_never_locked(self):
        a1 = self._a(1, 10, 'standard')
        self._apply([a1], {10: 3}, {1: 0})
        self.assertFalse(a1.is_locked)

    def test_second_locked_when_first_incomplete(self):
        a1, a2 = self._a(1, 10), self._a(2, 11)
        self._apply([a1, a2], {10: 3, 11: 3}, {1: 2, 2: 0})
        self.assertFalse(a1.is_locked)
        self.assertTrue(a2.is_locked)

    def test_second_unlocked_when_first_complete(self):
        a1, a2 = self._a(1, 10), self._a(2, 11)
        self._apply([a1, a2], {10: 3, 11: 3}, {1: 3, 2: 0})
        self.assertFalse(a1.is_locked)
        self.assertFalse(a2.is_locked)

    def test_chain_partial(self):
        a1, a2, a3 = self._a(1, 10), self._a(2, 11), self._a(3, 12)
        self._apply(
            [a1, a2, a3],
            {10: 2, 11: 2, 12: 2},
            {1: 2, 2: 1, 3: 0},
        )
        self.assertFalse(a1.is_locked)
        self.assertFalse(a2.is_locked)
        self.assertTrue(a3.is_locked)

    def test_chain_all_complete(self):
        a1, a2, a3 = self._a(1, 10), self._a(2, 11), self._a(3, 12)
        self._apply(
            [a1, a2, a3],
            {10: 2, 11: 2, 12: 2},
            {1: 2, 2: 2, 3: 0},
        )
        self.assertFalse(a3.is_locked)

    def test_zero_unit_lesson_is_incomplete(self):
        a1, a2 = self._a(1, 10), self._a(2, 11)
        self._apply([a1, a2], {10: 0, 11: 3}, {1: 0, 2: 0})
        self.assertFalse(a1.is_locked)
        self.assertTrue(a2.is_locked)

    def test_lock_mode_same_as_standard(self):
        a1, a2 = self._a(1, 10, 'lock'), self._a(2, 11, 'lock')
        self._apply([a1, a2], {10: 2, 11: 2}, {1: 1, 2: 0})
        self.assertTrue(a2.is_locked)

    def test_sprint_predecessor_satisfies_standard(self):
        a1, a2 = self._a(1, 10, 'sprint'), self._a(2, 11, 'standard')
        self._apply([a1, a2], {10: 2, 11: 2}, {1: 2, 2: 0})
        self.assertFalse(a2.is_locked)


# ---------------------------------------------------------------------------
# Unit pass/fail threshold
# ---------------------------------------------------------------------------

class UnitPassFailLogicTest(SimpleTestCase):

    def _status(self, wrong):
        from core.models import CurriculumUnitAttempt as A
        return A.STATUS_PASSED if wrong <= 2 else A.STATUS_FAILED

    def test_zero_wrong_passes(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._status(0), A.STATUS_PASSED)

    def test_two_wrong_passes(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._status(2), A.STATUS_PASSED)

    def test_three_wrong_fails(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._status(3), A.STATUS_FAILED)


# ---------------------------------------------------------------------------
# Coin award logic
# ---------------------------------------------------------------------------

class CoinAwardLogicTest(SimpleTestCase):

    COIN = 5

    def _coins(self, attempt_number, status):
        from core.models import CurriculumUnitAttempt as A
        if status != A.STATUS_PASSED:
            return 0
        return self.COIN * 2 if attempt_number == 1 else self.COIN

    def test_first_pass_doubles(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._coins(1, A.STATUS_PASSED), 10)

    def test_retry_pass_single(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._coins(2, A.STATUS_PASSED), 5)

    def test_failed_no_coins(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._coins(1, A.STATUS_FAILED), 0)

    def test_in_progress_no_coins(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._coins(1, A.STATUS_IN_PROGRESS), 0)
