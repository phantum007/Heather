from django.db import models


class AppUser(models.Model):
    ROLE_STUDENT = 'student'
    ROLE_TEACHER = 'teacher'
    ROLE_CHOICES = (
        (ROLE_STUDENT, 'Student'),
        (ROLE_TEACHER, 'Teacher'),
    )

    name = models.CharField(max_length=120)
    email = models.EmailField(max_length=180, unique=True)
    password = models.TextField()
    role = models.CharField(max_length=20, choices=ROLE_CHOICES)

    class Meta:
        db_table = 'users'
        managed = False

    @property
    def is_authenticated(self):
        return True


class Grade(models.Model):
    grade_name = models.CharField(max_length=60, unique=True)

    class Meta:
        db_table = 'grades'
        managed = False


class StudentProfile(models.Model):
    user = models.OneToOneField(AppUser, on_delete=models.CASCADE, db_column='user_id', related_name='student_profile')
    grade = models.ForeignKey(Grade, null=True, blank=True, on_delete=models.SET_NULL, db_column='grade_id', related_name='students')
    first_name = models.CharField(max_length=120, null=True, blank=True)
    last_name = models.CharField(max_length=120, null=True, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    father_name = models.CharField(max_length=120, null=True, blank=True)
    mother_name = models.CharField(max_length=120, null=True, blank=True)
    contact = models.CharField(max_length=40, null=True, blank=True)
    profile_photo = models.TextField(null=True, blank=True)

    class Meta:
        db_table = 'students'
        managed = False


class LessonType(models.Model):
    grade = models.ForeignKey(Grade, on_delete=models.CASCADE, db_column='grade_id', related_name='lesson_types')
    lesson_name = models.CharField(max_length=120)

    class Meta:
        db_table = 'lesson_types'
        managed = False


class SubLessonTypeMaster(models.Model):
    type_name = models.CharField(max_length=120, unique=True)

    class Meta:
        db_table = 'sub_lesson_type_master'
        managed = False


class SubLesson(models.Model):
    lesson_type = models.ForeignKey(LessonType, on_delete=models.CASCADE, db_column='lesson_type_id', related_name='sub_lessons')
    sub_lesson_type_master = models.ForeignKey(
        SubLessonTypeMaster,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        db_column='sub_lesson_type_master_id',
        related_name='sub_lessons',
    )
    sub_lesson_name = models.CharField(max_length=120)

    class Meta:
        db_table = 'sub_lessons'
        managed = False


class Chapter(models.Model):
    sub_lesson = models.ForeignKey(SubLesson, on_delete=models.CASCADE, db_column='sub_lesson_id', related_name='chapters')
    chapter_name = models.CharField(max_length=120)

    class Meta:
        db_table = 'chapters'
        managed = False


class Unit(models.Model):
    chapter = models.ForeignKey(Chapter, on_delete=models.CASCADE, db_column='chapter_id', related_name='units')
    unit_name = models.CharField(max_length=120)

    class Meta:
        db_table = 'units'
        managed = False


class Learning(models.Model):
    unit = models.ForeignKey(Unit, null=True, blank=True, on_delete=models.CASCADE, db_column='unit_id', related_name='learnings')
    chapter = models.ForeignKey(Chapter, null=True, blank=True, on_delete=models.CASCADE, db_column='chapter_id', related_name='learnings')
    learning_text = models.TextField()
    answer_text = models.TextField(null=True, blank=True)

    class Meta:
        db_table = 'learnings'
        managed = False


class Assignment(models.Model):
    KIND_HOMEWORK = 'homework'
    KIND_CLASSROOM = 'classroom'
    KIND_CHOICES = (
        (KIND_HOMEWORK, 'Homework'),
        (KIND_CLASSROOM, 'Classroom Lesson'),
    )

    teacher = models.ForeignKey(AppUser, on_delete=models.CASCADE, db_column='teacher_id', related_name='teacher_assignments')
    student = models.ForeignKey(AppUser, on_delete=models.CASCADE, db_column='student_id', related_name='student_assignments')
    lesson = models.ForeignKey(LessonType, on_delete=models.CASCADE, db_column='lesson_id', related_name='assignments')
    assigned_date = models.DateTimeField()
    assignment_kind = models.CharField(max_length=20, choices=KIND_CHOICES, default=KIND_HOMEWORK)
    available_on = models.DateField(null=True, blank=True)

    class Meta:
        db_table = 'assignments'
        managed = False


class Question(models.Model):
    assignment = models.ForeignKey(Assignment, on_delete=models.CASCADE, db_column='assignment_id', related_name='questions')
    question_text = models.TextField()
    correct_answer = models.CharField(max_length=120)

    class Meta:
        db_table = 'questions'
        managed = False


class StudentAnswer(models.Model):
    question = models.ForeignKey(Question, on_delete=models.CASCADE, db_column='question_id', related_name='answers')
    student = models.ForeignKey(AppUser, on_delete=models.CASCADE, db_column='student_id', related_name='answers')
    student_answer = models.CharField(max_length=120)
    is_correct = models.BooleanField()

    class Meta:
        db_table = 'student_answers'
        managed = False
        unique_together = ('question', 'student')
