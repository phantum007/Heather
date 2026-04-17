from django.test import SimpleTestCase


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
