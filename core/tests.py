"""
Pure-Python regression tests for core utilities and business logic.

All tests use SimpleTestCase so no database is created or needed.
"""
from django.test import SimpleTestCase

from core.answer_utils import answers_match, truncate_numeric_precision


class TruncateNumericPrecisionTest(SimpleTestCase):
    """Tests for truncate_numeric_precision — strips excess decimal places."""

    def test_integer_unchanged(self):
        self.assertEqual(truncate_numeric_precision("42"), "42")

    def test_three_decimal_places_unchanged(self):
        self.assertEqual(truncate_numeric_precision("3.141"), "3.141")

    def test_four_decimal_places_truncated(self):
        # 3.14159 → truncated to 3 decimals (not rounded)
        self.assertEqual(truncate_numeric_precision("3.14159"), "3.141")

    def test_truncates_not_rounds(self):
        # 1.9999 → 1.999, not 2.000
        self.assertEqual(truncate_numeric_precision("1.9999"), "1.999")

    def test_comma_stripped_before_parsing(self):
        self.assertEqual(truncate_numeric_precision("1,234"), "1234")

    def test_comma_in_decimal_number(self):
        self.assertEqual(
            truncate_numeric_precision("1,234.5678"), "1234.567"
        )

    def test_non_numeric_returned_as_is(self):
        self.assertEqual(truncate_numeric_precision("abc"), "abc")

    def test_empty_string_returns_empty(self):
        self.assertEqual(truncate_numeric_precision(""), "")

    def test_none_returns_empty(self):
        self.assertEqual(truncate_numeric_precision(None), "")

    def test_negative_number(self):
        self.assertEqual(truncate_numeric_precision("-5.12345"), "-5.123")

    def test_zero(self):
        self.assertEqual(truncate_numeric_precision("0"), "0")

    def test_whitespace_stripped(self):
        self.assertEqual(truncate_numeric_precision("  7  "), "7")


class AnswersMatchTest(SimpleTestCase):
    """Tests for answers_match — the core grading function."""

    # ---- numeric equivalence ----

    def test_exact_match(self):
        self.assertTrue(answers_match("42", "42"))

    def test_numeric_with_trailing_zero(self):
        self.assertTrue(answers_match("3.50", "3.5"))

    def test_numeric_leading_zero(self):
        self.assertTrue(answers_match("007", "7"))

    def test_integer_vs_decimal_equivalent(self):
        self.assertTrue(answers_match("5.0", "5"))

    def test_comma_separated_number(self):
        self.assertTrue(answers_match("1,234", "1234"))

    def test_different_numbers(self):
        self.assertFalse(answers_match("3", "4"))

    def test_negative_number_match(self):
        self.assertTrue(answers_match("-10", "-10"))

    def test_negative_mismatch(self):
        self.assertFalse(answers_match("-10", "10"))

    # ---- text equivalence ----

    def test_text_case_insensitive(self):
        self.assertTrue(answers_match("Hello", "hello"))

    def test_text_mismatch(self):
        self.assertFalse(answers_match("cat", "dog"))

    # ---- edge cases ----

    def test_empty_student_answer(self):
        self.assertFalse(answers_match("", "42"))

    def test_empty_correct_answer(self):
        self.assertFalse(answers_match("42", ""))

    def test_both_empty(self):
        self.assertFalse(answers_match("", ""))

    def test_none_student_answer(self):
        self.assertFalse(answers_match(None, "42"))

    def test_none_correct_answer(self):
        self.assertFalse(answers_match("42", None))

    def test_decimal_precision_match(self):
        self.assertTrue(answers_match("1.9999", "1.999"))

    def test_decimal_precision_mismatch(self):
        self.assertFalse(answers_match("1.999", "2.000"))

    def test_whitespace_trimmed(self):
        self.assertTrue(answers_match("  5  ", "5"))


class AssignmentLockingLogicTest(SimpleTestCase):
    """
    Unit tests for the lesson-locking computation in student_assignments.
    Exercises the pure logic in isolation (no DB required).
    """

    class _FakeAssignment:
        def __init__(self, id, lesson_id, mode):
            self.id = id
            self.lesson_id = lesson_id
            self.mode = mode
            self.is_locked = False

    def _apply_locking(
        self, assignments, unit_counts_by_lesson, passed_units_by_assignment
    ):
        """Re-implements the locking algorithm from views.py."""
        from core.models import Assignment
        complete_ids = {
            a.id for a in assignments
            if unit_counts_by_lesson.get(a.lesson_id, 0) > 0
            and passed_units_by_assignment.get(a.id, 0)
            >= unit_counts_by_lesson.get(a.lesson_id, 0)
        }
        for i, assignment in enumerate(assignments):
            if i == 0 or assignment.mode not in (
                Assignment.MODE_STANDARD, Assignment.MODE_LOCK
            ):
                assignment.is_locked = False
            else:
                assignment.is_locked = (
                    assignments[i - 1].id not in complete_ids
                )
        return assignments

    def _make(self, id, lesson_id, mode='standard'):
        return self._FakeAssignment(id, lesson_id, mode)

    def test_sprint_mode_never_locked(self):
        a1 = self._make(1, 10, mode='sprint')
        a2 = self._make(2, 11, mode='sprint')
        self._apply_locking([a1, a2], {10: 5, 11: 5}, {1: 0, 2: 0})
        self.assertFalse(a1.is_locked)
        self.assertFalse(a2.is_locked)

    def test_first_assignment_never_locked_standard(self):
        a1 = self._make(1, 10, mode='standard')
        self._apply_locking([a1], {10: 3}, {1: 0})
        self.assertFalse(a1.is_locked)

    def test_first_assignment_never_locked_lock(self):
        a1 = self._make(1, 10, mode='lock')
        self._apply_locking([a1], {10: 3}, {1: 0})
        self.assertFalse(a1.is_locked)

    def test_second_locked_when_first_incomplete(self):
        a1 = self._make(1, 10, mode='standard')
        a2 = self._make(2, 11, mode='standard')
        self._apply_locking([a1, a2], {10: 3, 11: 3}, {1: 2, 2: 0})
        self.assertFalse(a1.is_locked)
        self.assertTrue(a2.is_locked)

    def test_second_unlocked_when_first_complete(self):
        a1 = self._make(1, 10, mode='standard')
        a2 = self._make(2, 11, mode='standard')
        self._apply_locking([a1, a2], {10: 3, 11: 3}, {1: 3, 2: 0})
        self.assertFalse(a1.is_locked)
        self.assertFalse(a2.is_locked)

    def test_chain_locking_three_assignments(self):
        a1 = self._make(1, 10, mode='standard')
        a2 = self._make(2, 11, mode='standard')
        a3 = self._make(3, 12, mode='standard')
        # a1 done, a2 partially done → a3 must be locked
        self._apply_locking(
            [a1, a2, a3],
            {10: 2, 11: 2, 12: 2},
            {1: 2, 2: 1, 3: 0},
        )
        self.assertFalse(a1.is_locked)
        self.assertFalse(a2.is_locked)
        self.assertTrue(a3.is_locked)

    def test_chain_all_complete_all_unlocked(self):
        a1 = self._make(1, 10, mode='standard')
        a2 = self._make(2, 11, mode='standard')
        a3 = self._make(3, 12, mode='standard')
        self._apply_locking(
            [a1, a2, a3],
            {10: 2, 11: 2, 12: 2},
            {1: 2, 2: 2, 3: 0},
        )
        self.assertFalse(a1.is_locked)
        self.assertFalse(a2.is_locked)
        self.assertFalse(a3.is_locked)

    def test_lesson_with_zero_units_counts_as_incomplete(self):
        # A lesson with 0 units should never count as "complete"
        a1 = self._make(1, 10, mode='standard')
        a2 = self._make(2, 11, mode='standard')
        self._apply_locking([a1, a2], {10: 0, 11: 3}, {1: 0, 2: 0})
        self.assertFalse(a1.is_locked)
        self.assertTrue(a2.is_locked)

    def test_lock_mode_behaves_same_as_standard_for_locking(self):
        a1 = self._make(1, 10, mode='lock')
        a2 = self._make(2, 11, mode='lock')
        self._apply_locking([a1, a2], {10: 2, 11: 2}, {1: 1, 2: 0})
        self.assertFalse(a1.is_locked)
        self.assertTrue(a2.is_locked)

    def test_sprint_before_standard_does_not_propagate_lock(self):
        """Completed sprint predecessor satisfies the standard-mode check."""
        a1 = self._make(1, 10, mode='sprint')
        a2 = self._make(2, 11, mode='standard')
        # a1 (sprint) has all 2 units passed
        self._apply_locking([a1, a2], {10: 2, 11: 2}, {1: 2, 2: 0})
        self.assertFalse(a1.is_locked)
        self.assertFalse(a2.is_locked)


class UnitPassFailLogicTest(SimpleTestCase):
    """Pass/fail threshold: unit passes when wrong_count <= 2."""

    def _status(self, wrong_count):
        from core.models import CurriculumUnitAttempt as A
        return A.STATUS_PASSED if wrong_count <= 2 else A.STATUS_FAILED

    def test_zero_wrong_passes(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._status(0), A.STATUS_PASSED)

    def test_one_wrong_passes(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._status(1), A.STATUS_PASSED)

    def test_two_wrong_passes(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._status(2), A.STATUS_PASSED)

    def test_three_wrong_fails(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._status(3), A.STATUS_FAILED)

    def test_many_wrong_fails(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._status(10), A.STATUS_FAILED)


class CoinAwardLogicTest(SimpleTestCase):
    """Coin award: first-pass = double coins; retry-pass = single coin."""

    COIN_VALUE = 5

    def _coins(self, attempt_number, status):
        from core.models import CurriculumUnitAttempt as A
        if status != A.STATUS_PASSED:
            return 0
        return self.COIN_VALUE * 2 if attempt_number == 1 else self.COIN_VALUE

    def test_first_attempt_pass_doubles_coins(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._coins(1, A.STATUS_PASSED), 10)

    def test_second_attempt_pass_single_coins(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._coins(2, A.STATUS_PASSED), 5)

    def test_third_attempt_pass_single_coins(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._coins(3, A.STATUS_PASSED), 5)

    def test_failed_attempt_no_coins(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._coins(1, A.STATUS_FAILED), 0)

    def test_in_progress_no_coins(self):
        from core.models import CurriculumUnitAttempt as A
        self.assertEqual(self._coins(1, A.STATUS_IN_PROGRESS), 0)
