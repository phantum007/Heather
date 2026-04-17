from django.test import SimpleTestCase

from core.models import CurriculumUnitAttempt as A


class CoinAwardLogicTest(SimpleTestCase):

    COIN = 5

    def _coins(self, attempt_number, status):
        if status != A.STATUS_PASSED:
            return 0
        return self.COIN * 2 if attempt_number == 1 else self.COIN

    def test_first_pass_doubles(self):
        self.assertEqual(self._coins(1, A.STATUS_PASSED), 10)

    def test_retry_pass_single(self):
        self.assertEqual(self._coins(2, A.STATUS_PASSED), 5)

    def test_failed_no_coins(self):
        self.assertEqual(self._coins(1, A.STATUS_FAILED), 0)

    def test_in_progress_no_coins(self):
        self.assertEqual(self._coins(1, A.STATUS_IN_PROGRESS), 0)
