from django.test import SimpleTestCase

from core.answer_utils import (
    _normalize_numeric_answer,
    answers_match,
    truncate_numeric_precision,
)


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
        self.assertEqual(truncate_numeric_precision("1,234.5678"), "1234.567")

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


class NormalizeNumericAnswerTest(SimpleTestCase):

    def test_empty_string_returns_none(self):
        self.assertIsNone(_normalize_numeric_answer(""))

    def test_none_returns_none(self):
        self.assertIsNone(_normalize_numeric_answer(None))

    def test_integer_string(self):
        self.assertEqual(_normalize_numeric_answer("42"), "42")

    def test_trailing_zeros_stripped(self):
        self.assertEqual(_normalize_numeric_answer("3.50"), "3.5")

    def test_non_numeric_returns_none(self):
        self.assertIsNone(_normalize_numeric_answer("abc"))

    def test_point_zero_becomes_integer(self):
        self.assertEqual(_normalize_numeric_answer("5.0"), "5")


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
