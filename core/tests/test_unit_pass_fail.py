from django.test import SimpleTestCase

from core.models import CurriculumUnitAttempt as A


class UnitPassFailLogicTest(SimpleTestCase):

    def _status(self, wrong):
        return A.STATUS_PASSED if wrong <= 2 else A.STATUS_FAILED

    def test_zero_wrong_passes(self):
        self.assertEqual(self._status(0), A.STATUS_PASSED)

    def test_two_wrong_passes(self):
        self.assertEqual(self._status(2), A.STATUS_PASSED)

    def test_three_wrong_fails(self):
        self.assertEqual(self._status(3), A.STATUS_FAILED)
