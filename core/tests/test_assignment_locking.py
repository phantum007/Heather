from django.test import SimpleTestCase

from core.models import Assignment


class AssignmentLockingLogicTest(SimpleTestCase):

    class _Fake:
        def __init__(self, id, lesson_id, mode):
            self.id = id
            self.lesson_id = lesson_id
            self.mode = mode
            self.is_locked = False

    def _apply(self, assignments, unit_counts, passed_counts):
        complete = {
            a.id for a in assignments
            if unit_counts.get(a.lesson_id, 0) > 0
            and passed_counts.get(a.id, 0) >= unit_counts.get(a.lesson_id, 0)
        }
        for i, a in enumerate(assignments):
            if i == 0 or a.mode not in (Assignment.MODE_STANDARD, Assignment.MODE_LOCK):
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
        self._apply([a1, a2, a3], {10: 2, 11: 2, 12: 2}, {1: 2, 2: 1, 3: 0})
        self.assertFalse(a1.is_locked)
        self.assertFalse(a2.is_locked)
        self.assertTrue(a3.is_locked)

    def test_chain_all_complete(self):
        a1, a2, a3 = self._a(1, 10), self._a(2, 11), self._a(3, 12)
        self._apply([a1, a2, a3], {10: 2, 11: 2, 12: 2}, {1: 2, 2: 2, 3: 0})
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
