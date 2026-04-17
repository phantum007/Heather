"""Integration tests: teacher curriculum views (add/edit/delete grades, lessons, units, questions)."""
import pytest

from core.models import CurriculumQuestion, Grade, LessonType, SubLesson, SubLessonTypeMaster, Unit
from ui.features.conftest import login


@pytest.mark.django_db
class TestTeacherCurriculumGet:

    def test_unauthenticated_redirects(self, client):
        r = client.get('/teacher/curriculum/')
        assert r.status_code == 302

    def test_teacher_sees_curriculum_page(self, client, teacher):
        login(client, teacher.id)
        r = client.get('/teacher/curriculum/')
        assert r.status_code == 200


@pytest.mark.django_db
class TestTeacherAddGrade:

    def test_add_grade_creates_grade(self, client, teacher):
        login(client, teacher.id)
        r = client.post('/teacher/curriculum/', {
            'action': 'add_grade', 'name': 'NewGrade', 'active_tab': 'grade-panel',
        })
        assert r.status_code == 302
        assert Grade.objects.filter(grade_name='NewGrade').exists()

    def test_add_grade_empty_name_stays_and_does_not_create(self, client, teacher):
        login(client, teacher.id)
        before = Grade.objects.count()
        r = client.post('/teacher/curriculum/', {
            'action': 'add_grade', 'name': '', 'active_tab': 'grade-panel',
        })
        assert r.status_code == 302
        assert Grade.objects.count() == before

    def test_add_duplicate_grade_does_not_create(self, client, teacher, grade):
        login(client, teacher.id)
        before = Grade.objects.count()
        r = client.post('/teacher/curriculum/', {
            'action': 'add_grade', 'name': grade.grade_name, 'active_tab': 'grade-panel',
        })
        assert r.status_code == 302
        assert Grade.objects.count() == before


@pytest.mark.django_db
class TestTeacherAddLesson:

    def test_add_lesson_creates_lesson(self, client, teacher, grade):
        login(client, teacher.id)
        r = client.post('/teacher/curriculum/', {
            'action': 'add_lesson', 'name': 'Subtraction',
            'parent_id': str(grade.id), 'active_tab': 'lesson-panel',
        })
        assert r.status_code == 302
        assert LessonType.objects.filter(lesson_name='Subtraction', grade=grade).exists()

    def test_add_lesson_missing_parent_does_not_create(self, client, teacher):
        login(client, teacher.id)
        before = LessonType.objects.count()
        r = client.post('/teacher/curriculum/', {
            'action': 'add_lesson', 'name': 'Subtraction', 'parent_id': '',
            'active_tab': 'lesson-panel',
        })
        assert r.status_code == 302
        assert LessonType.objects.count() == before


@pytest.mark.django_db
class TestTeacherAddUnit:

    def test_add_unit_creates_unit(self, client, teacher, sub_lesson):
        login(client, teacher.id)
        r = client.post('/teacher/curriculum/', {
            'action': 'add_unit', 'name': 'Unit 99',
            'parent_id': str(sub_lesson.id), 'active_tab': 'unit-panel',
        })
        assert r.status_code == 302
        assert Unit.objects.filter(unit_name='Unit 99', sub_lesson=sub_lesson).exists()

    def test_add_unit_missing_name_does_not_create(self, client, teacher, sub_lesson):
        login(client, teacher.id)
        before = Unit.objects.count()
        client.post('/teacher/curriculum/', {
            'action': 'add_unit', 'name': '',
            'parent_id': str(sub_lesson.id), 'active_tab': 'unit-panel',
        })
        assert Unit.objects.count() == before


@pytest.mark.django_db
class TestTeacherAddQuestion:

    def test_add_question_creates_question(self, client, teacher, unit):
        login(client, teacher.id)
        r = client.post('/teacher/curriculum/', {
            'action': 'add_question', 'question_text': '2+2',
            'answer_text': '4', 'parent_id': str(unit.id),
            'order': '1', 'active_tab': 'question-panel',
        })
        assert r.status_code == 302
        assert CurriculumQuestion.objects.filter(question_text='2+2', unit=unit).exists()

    def test_add_question_missing_fields_does_not_create(self, client, teacher, unit):
        login(client, teacher.id)
        before = CurriculumQuestion.objects.count()
        client.post('/teacher/curriculum/', {
            'action': 'add_question', 'question_text': '',
            'answer_text': '', 'parent_id': str(unit.id),
            'order': '', 'active_tab': 'question-panel',
        })
        assert CurriculumQuestion.objects.count() == before


@pytest.mark.django_db
class TestTeacherEditCurriculumItem:

    def test_get_edit_grade_renders(self, client, teacher, grade):
        login(client, teacher.id)
        r = client.get(f'/teacher/curriculum/grade/{grade.id}/edit/')
        assert r.status_code == 200

    def test_post_edit_grade_updates(self, client, teacher, grade):
        login(client, teacher.id)
        r = client.post(f'/teacher/curriculum/grade/{grade.id}/edit/', {'value': 'Renamed Grade'})
        assert r.status_code == 302
        grade.refresh_from_db()
        assert grade.grade_name == 'Renamed Grade'

    def test_post_edit_grade_empty_value_stays(self, client, teacher, grade):
        login(client, teacher.id)
        r = client.post(f'/teacher/curriculum/grade/{grade.id}/edit/', {'value': ''})
        assert r.status_code == 200

    def test_edit_question_updates_text_and_answer(self, client, teacher, curriculum_question):
        login(client, teacher.id)
        r = client.post(
            f'/teacher/curriculum/question/{curriculum_question.id}/edit/',
            {'value': '3+3', 'answer': '6', 'order': '1'},
        )
        assert r.status_code == 302
        curriculum_question.refresh_from_db()
        assert curriculum_question.question_text == '3+3'
        assert curriculum_question.answer_text == '6'


@pytest.mark.django_db
class TestTeacherDeleteCurriculumItem:

    def test_delete_grade_removes_it(self, client, teacher):
        g = Grade.objects.create(grade_name='To Delete Grade')
        login(client, teacher.id)
        r = client.post(f'/teacher/curriculum/grade/{g.id}/delete/')
        assert r.status_code == 302
        assert not Grade.objects.filter(id=g.id).exists()

    def test_unknown_item_type_raises_404(self, client, teacher, grade):
        login(client, teacher.id)
        r = client.post(f'/teacher/curriculum/unknown/{grade.id}/delete/')
        assert r.status_code == 404


@pytest.mark.django_db
class TestTeacherCurriculumGradeTree:

    def test_returns_json_with_html(self, client, teacher, grade):
        login(client, teacher.id)
        r = client.get(f'/teacher/curriculum/grade/{grade.id}/tree/')
        assert r.status_code == 200
        assert 'html' in r.json()

    def test_unauthenticated_redirects(self, client, grade):
        r = client.get(f'/teacher/curriculum/grade/{grade.id}/tree/')
        assert r.status_code == 302
