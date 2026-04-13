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
    coins = models.PositiveIntegerField(default=0)

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


class Unit(models.Model):
    sub_lesson = models.ForeignKey(SubLesson, on_delete=models.CASCADE, db_column='sub_lesson_id', related_name='units')
    unit_name = models.CharField(max_length=120)

    class Meta:
        db_table = 'units'
        managed = False


class CurriculumQuestion(models.Model):
    unit = models.ForeignKey(Unit, null=True, blank=True, on_delete=models.CASCADE, db_column='unit_id', related_name='curriculum_questions')
    question_text = models.TextField()
    answer_text = models.TextField(null=True, blank=True)
    order = models.PositiveIntegerField(null=True, blank=True)

    class Meta:
        db_table = 'curriculum_questions'
        managed = False


class Assignment(models.Model):
    KIND_HOMEWORK = 'homework'
    KIND_CLASSROOM = 'classroom'
    KIND_CHOICES = (
        (KIND_HOMEWORK, 'Homework'),
        (KIND_CLASSROOM, 'Classroom Lesson'),
    )
    MODE_SPRINT = 'sprint'
    MODE_STANDARD = 'standard'
    MODE_LOCK = 'lock'
    MODE_CHOICES = (
        (MODE_SPRINT, 'Sprint'),
        (MODE_STANDARD, 'Standard'),
        (MODE_LOCK, 'Lock'),
    )

    teacher = models.ForeignKey(AppUser, on_delete=models.CASCADE, db_column='teacher_id', related_name='teacher_assignments')
    student = models.ForeignKey(AppUser, on_delete=models.CASCADE, db_column='student_id', related_name='student_assignments')
    lesson = models.ForeignKey(LessonType, on_delete=models.CASCADE, db_column='lesson_id', related_name='assignments')
    assigned_date = models.DateTimeField()
    assignment_kind = models.CharField(max_length=20, choices=KIND_CHOICES, default=KIND_HOMEWORK)
    available_on = models.DateField(null=True, blank=True)
    mode = models.CharField(max_length=20, choices=MODE_CHOICES, default=MODE_SPRINT)

    class Meta:
        db_table = 'assignments'
        managed = False


class Question(models.Model):
    assignment = models.ForeignKey(Assignment, on_delete=models.CASCADE, db_column='assignment_id', related_name='questions')
    question_text = models.TextField()
    correct_answer = models.CharField(max_length=120)
    order = models.PositiveIntegerField(null=True, blank=True)

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


class CurriculumUnitAttempt(models.Model):
    STATUS_IN_PROGRESS = 'in_progress'
    STATUS_PASSED = 'passed'
    STATUS_FAILED = 'failed'
    STATUS_CHOICES = (
        (STATUS_IN_PROGRESS, 'In Progress'),
        (STATUS_PASSED, 'Passed'),
        (STATUS_FAILED, 'Failed'),
    )

    student = models.ForeignKey(AppUser, on_delete=models.CASCADE, db_column='student_id', related_name='curriculum_unit_attempts')
    unit = models.ForeignKey(Unit, on_delete=models.CASCADE, db_column='unit_id', related_name='attempts')
    assignment = models.ForeignKey(Assignment, null=True, blank=True, on_delete=models.CASCADE, db_column='assignment_id', related_name='curriculum_unit_attempts')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=STATUS_IN_PROGRESS)
    attempt_number = models.PositiveIntegerField(default=1)
    elapsed_seconds = models.PositiveIntegerField(default=0)
    correct_count = models.PositiveIntegerField(default=0)
    wrong_count = models.PositiveIntegerField(default=0)
    completed_at = models.DateTimeField(null=True, blank=True)
    updated_at = models.DateTimeField()
    created_at = models.DateTimeField()

    class Meta:
        db_table = 'curriculum_unit_attempts'
        managed = False


class CurriculumQuestionAttempt(models.Model):
    unit_attempt = models.ForeignKey(CurriculumUnitAttempt, on_delete=models.CASCADE, db_column='unit_attempt_id', related_name='question_attempts')
    curriculum_question = models.ForeignKey(CurriculumQuestion, on_delete=models.CASCADE, db_column='curriculum_question_id', related_name='attempts')
    student_answer = models.TextField()
    is_correct = models.BooleanField()
    attempted_at = models.DateTimeField()

    class Meta:
        db_table = 'curriculum_question_attempts'
        managed = False


class Toy(models.Model):
    name = models.CharField(max_length=120)
    image = models.TextField(null=True, blank=True)
    coin_value = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField()

    class Meta:
        db_table = 'toys'
        managed = False


class ToyRedemption(models.Model):
    student = models.ForeignKey(AppUser, on_delete=models.CASCADE, db_column='student_id', related_name='toy_redemptions')
    toy = models.ForeignKey(Toy, on_delete=models.CASCADE, db_column='toy_id', related_name='redemptions')
    coins_spent = models.PositiveIntegerField()
    redeemed_at = models.DateTimeField()

    class Meta:
        db_table = 'toy_redemptions'
        managed = False
