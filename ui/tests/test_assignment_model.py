from django.test import SimpleTestCase

from core.models import Assignment


class AssignmentModelConstantsTest(SimpleTestCase):

    def test_modes(self):
        self.assertEqual(Assignment.MODE_SPRINT, 'sprint')
        self.assertEqual(Assignment.MODE_STANDARD, 'standard')
        self.assertEqual(Assignment.MODE_LOCK, 'lock')

    def test_mode_choices(self):
        values = [m[0] for m in Assignment.MODE_CHOICES]
        for mode in ('sprint', 'standard', 'lock'):
            self.assertIn(mode, values)

    def test_kinds(self):
        self.assertEqual(Assignment.KIND_HOMEWORK, 'homework')
        self.assertEqual(Assignment.KIND_CLASSROOM, 'classroom')


class AssignmentModeValidationTest(SimpleTestCase):

    def _val(self, raw):
        mode = (raw or '').strip()
        if mode not in {Assignment.MODE_SPRINT, Assignment.MODE_STANDARD, Assignment.MODE_LOCK}:
            mode = Assignment.MODE_SPRINT
        return mode

    def test_sprint(self): self.assertEqual(self._val('sprint'), 'sprint')
    def test_standard(self): self.assertEqual(self._val('standard'), 'standard')
    def test_lock(self): self.assertEqual(self._val('lock'), 'lock')
    def test_empty(self): self.assertEqual(self._val(''), 'sprint')
    def test_unknown(self): self.assertEqual(self._val('bad'), 'sprint')
    def test_uppercase(self): self.assertEqual(self._val('SPRINT'), 'sprint')
    def test_none(self): self.assertEqual(self._val(None), 'sprint')
