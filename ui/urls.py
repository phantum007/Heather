from django.urls import path

from . import views

urlpatterns = [
    path('', views.home, name='ui-home'),
    path('login/', views.login_view, name='ui-login'),
    path('logout/', views.logout_view, name='ui-logout'),
    path('media/<path:path>', views.serve_media, name='ui-serve-media'),
    path('teacher/', views.teacher_dashboard, name='ui-teacher-dashboard'),
    path('teacher/students/', views.teacher_students, name='ui-teacher-students'),
    path('teacher/students/add/', views.teacher_add_student, name='ui-teacher-add-student'),
    path('teacher/students/<int:student_id>/edit/', views.teacher_edit_student, name='ui-teacher-edit-student'),
    path('teacher/students/<int:student_id>/delete/', views.teacher_delete_student, name='ui-teacher-delete-student'),
    path('teacher/curriculum/', views.teacher_curriculum, name='ui-teacher-curriculum'),
    path('teacher/curriculum/grade/<int:grade_id>/tree/', views.teacher_curriculum_grade_tree, name='ui-teacher-curriculum-grade-tree'),
    path('teacher/curriculum/<str:item_type>/<int:item_id>/edit/', views.teacher_edit_curriculum_item, name='ui-teacher-edit-curriculum-item'),
    path('teacher/curriculum/<str:item_type>/<int:item_id>/delete/', views.teacher_delete_curriculum_item, name='ui-teacher-delete-curriculum-item'),
    path('teacher/profile/', views.teacher_profile, name='ui-teacher-profile'),
    path('teacher/create-assignment/', views.teacher_create_assignment, name='ui-teacher-create-assignment'),
    path('teacher/results/', views.teacher_results, name='ui-teacher-results'),
    path('student/', views.student_dashboard, name='ui-student-dashboard'),
    path('student/profile/', views.student_profile, name='ui-student-profile'),
    path('student/assignments/', views.student_assignments, name='ui-student-assignments'),
    path('student/unit-practice/submit/', views.student_submit_unit_question, name='ui-student-unit-practice-submit'),
]
