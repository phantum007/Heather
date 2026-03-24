from django.urls import path

from .views import (
    AssignmentResultsView,
    AssignmentsByStudentView,
    CreateAssignmentView,
    CreateQuestionsOnlyView,
    GradesLessonsView,
    HealthView,
    LoginView,
    MyAssignmentsView,
    RegisterView,
    StudentsView,
    SubmitAnswersView,
)

urlpatterns = [
    path('health', HealthView.as_view()),
    path('login', LoginView.as_view()),
    path('register', RegisterView.as_view()),
    path('students', StudentsView.as_view()),
    path('grades-lessons', GradesLessonsView.as_view()),
    path('assignments', CreateAssignmentView.as_view()),
    path('questions', CreateQuestionsOnlyView.as_view()),
    path('assignments/<int:student_id>', AssignmentsByStudentView.as_view()),
    path('assignment-results/<int:assignment_id>', AssignmentResultsView.as_view()),
    path('my-assignments', MyAssignmentsView.as_view()),
    path('submit-answers', SubmitAnswersView.as_view()),
]
