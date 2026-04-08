from django.db import transaction
from django.db.models import Exists, OuterRef
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from .answer_utils import answers_match, truncate_numeric_precision
from .models import Assignment, Grade, LessonType, Question, StudentAnswer, StudentProfile
from .permissions import IsAuthenticatedUser, IsStudent, IsTeacher
from .serializers import (
    LoginSerializer,
    RegisterSerializer,
    TeacherProfileSerializer,
    build_token,
    serialize_user,
)


def _get_answer_for_student(question, student_id):
    return next((item for item in question.answers.all() if item.student_id == student_id), None)


def _serialize_student_assignment(assignment, current_student_id):
    questions = []
    for question in assignment.questions.all().order_by('order', 'id'):
        answer = _get_answer_for_student(question, current_student_id)
        questions.append(
            {
                'id': question.id,
                'order': question.order,
                'questionText': question.question_text,
                'correctAnswer': question.correct_answer,
                'studentAnswer': answer.student_answer if answer else None,
                'isCorrect': answer.is_correct if answer else None,
            }
        )

    return {
        'assignment_id': assignment.id,
        'assigned_date': assignment.assigned_date,
        'lesson_name': assignment.lesson.lesson_name,
        'grade_name': assignment.lesson.grade.grade_name,
        'teacher_name': assignment.teacher.name,
        'questions': questions,
    }


def _serialize_teacher_assignment(assignment):
    questions = []
    for question in assignment.questions.all().order_by('order', 'id'):
        answer = _get_answer_for_student(question, assignment.student_id)
        questions.append(
            {
                'questionId': question.id,
                'order': question.order,
                'questionText': question.question_text,
                'correctAnswer': question.correct_answer,
                'studentAnswer': answer.student_answer if answer else None,
                'isCorrect': answer.is_correct if answer else None,
            }
        )

    return {
        'assignment_id': assignment.id,
        'assigned_date': assignment.assigned_date,
        'lesson_name': assignment.lesson.lesson_name,
        'grade_name': assignment.lesson.grade.grade_name,
        'teacher_name': assignment.teacher.name,
        'questions': questions,
    }


class HealthView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        return Response({'status': 'ok', 'service': 'abacus-backend-django'})


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if not serializer.is_valid():
            if 'message' in serializer.errors:
                return Response({'message': serializer.errors['message'][0]}, status=status.HTTP_400_BAD_REQUEST)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        user = serializer.save()
        return Response(
            {
                'user': serialize_user(user),
                'token': build_token(user),
            },
            status=status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({'message': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

        user = serializer.validated_data['user']
        return Response(
            {
                'token': build_token(user),
                'user': serialize_user(user),
            }
        )


class TeacherProfileView(APIView):
    permission_classes = [IsAuthenticatedUser, IsTeacher]

    def get(self, request):
        return Response({'user': serialize_user(request.user)})

    def patch(self, request):
        serializer = TeacherProfileSerializer(data=request.data, context={'user': request.user})
        if not serializer.is_valid():
            if 'message' in serializer.errors:
                return Response({'message': serializer.errors['message'][0]}, status=status.HTTP_400_BAD_REQUEST)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        user = serializer.update(request.user, serializer.validated_data)
        return Response(
            {
                'user': serialize_user(user),
                'token': build_token(user),
            }
        )


class StudentsView(APIView):
    permission_classes = [IsAuthenticatedUser, IsTeacher]

    def get(self, request):
        students = StudentProfile.objects.select_related('user', 'grade').order_by('user__name')
        return Response(
            [
                {
                    'id': profile.user.id,
                    'name': profile.user.name,
                    'email': profile.user.email,
                    'grade_id': profile.grade_id,
                    'grade_name': profile.grade.grade_name if profile.grade else None,
                }
                for profile in students
            ]
        )


class GradesLessonsView(APIView):
    permission_classes = [IsAuthenticatedUser, IsTeacher]

    def get(self, request):
        grades = Grade.objects.prefetch_related('lesson_types').order_by('id')
        return Response(
            [
                {
                    'id': grade.id,
                    'gradeName': grade.grade_name,
                    'lessonTypes': [
                        {
                            'id': lesson.id,
                            'lessonName': lesson.lesson_name,
                        }
                        for lesson in grade.lesson_types.all().order_by('id')
                    ],
                }
                for grade in grades
            ]
        )


class CreateAssignmentView(APIView):
    permission_classes = [IsAuthenticatedUser, IsTeacher]

    def post(self, request):
        student_id = request.data.get('studentId')
        lesson_id = request.data.get('lessonId')
        questions = request.data.get('questions')

        if not student_id or not lesson_id or not isinstance(questions, list) or not questions:
            return Response(
                {'message': 'studentId, lessonId and non-empty questions[] are required'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        invalid_question = next(
            (
                question
                for question in questions
                if not question.get('questionText') or question.get('correctAnswer') in (None, '')
            ),
            None,
        )
        if invalid_question:
            return Response(
                {'message': 'Each question must include questionText and correctAnswer'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            lesson = LessonType.objects.select_related('grade').get(id=lesson_id)
        except LessonType.DoesNotExist:
            return Response({'message': 'Lesson not found'}, status=status.HTTP_404_NOT_FOUND)

        with transaction.atomic():
            Assignment.objects.filter(
                student_id=student_id,
            ).exclude(
                lesson__grade_id=lesson.grade_id,
            ).delete()
            Assignment.objects.filter(
                student_id=student_id,
                lesson__grade_id=lesson.grade_id,
            ).delete()
            assignment = Assignment.objects.create(
                teacher_id=request.user.id,
                student_id=student_id,
                lesson_id=lesson_id,
                assigned_date=timezone.now(),
            )
            Question.objects.bulk_create(
                [
                    Question(
                        assignment=assignment,
                        question_text=question['questionText'],
                        correct_answer=str(question['correctAnswer']),
                        order=question.get('order', index),
                    )
                    for index, question in enumerate(questions, start=1)
                ]
            )

        created_questions = assignment.questions.all().order_by('order', 'id')
        return Response(
            {
                'assignment': {
                    'id': assignment.id,
                    'teacher_id': assignment.teacher_id,
                    'student_id': assignment.student_id,
                    'lesson_id': assignment.lesson_id,
                    'assigned_date': assignment.assigned_date,
                },
                'questions': [
                    {
                        'id': question.id,
                        'assignment_id': question.assignment_id,
                        'order': question.order,
                        'question_text': question.question_text,
                        'correct_answer': question.correct_answer,
                    }
                    for question in created_questions
                ],
            },
            status=status.HTTP_201_CREATED,
        )


class CreateQuestionsOnlyView(APIView):
    permission_classes = [IsAuthenticatedUser, IsTeacher]

    def post(self, request):
        assignment_id = request.data.get('assignmentId')
        questions = request.data.get('questions')

        if not assignment_id or not isinstance(questions, list) or not questions:
            return Response(
                {'message': 'assignmentId and non-empty questions[] are required'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        invalid_question = next(
            (
                question
                for question in questions
                if not question.get('questionText') or question.get('correctAnswer') in (None, '')
            ),
            None,
        )
        if invalid_question:
            return Response(
                {'message': 'Each question must include questionText and correctAnswer'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        Question.objects.bulk_create(
            [
                Question(
                    assignment_id=assignment_id,
                    question_text=question['questionText'],
                    correct_answer=str(question['correctAnswer']),
                    order=question.get('order', index),
                )
                for index, question in enumerate(questions, start=1)
            ]
        )
        created_questions = Question.objects.filter(assignment_id=assignment_id).order_by('-id')[: len(questions)]
        return Response(
            [
                {
                    'id': question.id,
                    'assignment_id': question.assignment_id,
                    'order': question.order,
                    'question_text': question.question_text,
                    'correct_answer': question.correct_answer,
                }
                for question in reversed(created_questions)
            ],
            status=status.HTTP_201_CREATED,
        )


class AssignmentsByStudentView(APIView):
    permission_classes = [IsAuthenticatedUser, IsTeacher]

    def get(self, request, student_id):
        assignments = (
            Assignment.objects.filter(student_id=student_id)
            .select_related('lesson__grade', 'teacher')
            .prefetch_related('questions__answers')
            .order_by('-assigned_date')
        )
        return Response([_serialize_teacher_assignment(assignment) for assignment in assignments])


class AssignmentResultsView(APIView):
    permission_classes = [IsAuthenticatedUser, IsTeacher]

    def get(self, request, assignment_id):
        try:
            assignment = (
                Assignment.objects.select_related('student', 'lesson__grade')
                .prefetch_related('questions__answers')
                .get(id=assignment_id)
            )
        except Assignment.DoesNotExist:
            return Response({'message': 'Assignment not found'}, status=status.HTTP_404_NOT_FOUND)

        questions = []
        correct = 0
        for question in assignment.questions.all().order_by('order', 'id'):
            answer = _get_answer_for_student(question, assignment.student_id)
            if answer and answer.is_correct:
                correct += 1
            questions.append(
                {
                    'questionId': question.id,
                    'order': question.order,
                    'questionText': question.question_text,
                    'correctAnswer': question.correct_answer,
                    'studentAnswer': answer.student_answer if answer else None,
                    'isCorrect': answer.is_correct if answer else None,
                }
            )

        total = len(questions)
        return Response(
            {
                'assignmentId': assignment.id,
                'studentName': assignment.student.name,
                'lessonName': assignment.lesson.lesson_name,
                'gradeName': assignment.lesson.grade.grade_name,
                'total': total,
                'correct': correct,
                'percentage': round((correct / total) * 100) if total else 0,
                'questions': questions,
            }
        )


class MyAssignmentsView(APIView):
    permission_classes = [IsAuthenticatedUser, IsStudent]

    def get(self, request):
        submitted_answers = StudentAnswer.objects.filter(
            question__assignment_id=OuterRef('pk'),
            student_id=request.user.id,
        )
        assignments = (
            Assignment.objects.filter(student_id=request.user.id)
            .select_related('lesson__grade', 'teacher')
            .prefetch_related('questions__answers')
            .annotate(is_submitted=Exists(submitted_answers))
            .order_by('-assigned_date')
        )
        response = []
        for assignment in assignments:
            payload = _serialize_student_assignment(assignment, request.user.id)
            payload['is_submitted'] = assignment.is_submitted
            response.append(payload)
        return Response(response)


class SubmitAnswersView(APIView):
    permission_classes = [IsAuthenticatedUser, IsStudent]

    def post(self, request):
        answers = request.data.get('answers')
        if not isinstance(answers, list) or not answers:
            return Response({'message': 'answers[] is required'}, status=status.HTTP_400_BAD_REQUEST)

        invalid_answer = next(
            (
                answer
                for answer in answers
                if not answer.get('questionId') or answer.get('studentAnswer') in (None, '')
            ),
            None,
        )
        if invalid_answer:
            return Response(
                {'message': 'Each answer must include questionId and studentAnswer'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        result_details = []
        score = 0
        with transaction.atomic():
            for answer in answers:
                try:
                    question = Question.objects.get(id=answer['questionId'])
                except Question.DoesNotExist:
                    return Response(
                        {'message': f"Question {answer['questionId']} not found"},
                        status=status.HTTP_400_BAD_REQUEST,
                    )

                student_answer = truncate_numeric_precision(answer['studentAnswer'])
                is_correct = answers_match(student_answer, question.correct_answer)
                StudentAnswer.objects.update_or_create(
                    question=question,
                    student_id=request.user.id,
                    defaults={
                        'student_answer': student_answer,
                        'is_correct': is_correct,
                    },
                )
                if is_correct:
                    score += 1
                result_details.append(
                    {
                        'questionId': question.id,
                        'studentAnswer': str(answer['studentAnswer']),
                        'correctAnswer': question.correct_answer,
                        'isCorrect': is_correct,
                    }
                )

        total = len(answers)
        return Response(
            {
                'total': total,
                'correct': score,
                'percentage': round((score / total) * 100) if total else 0,
                'details': result_details,
            }
        )
