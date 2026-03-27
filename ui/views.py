import bcrypt
import os
from uuid import uuid4

from django.conf import settings
from django.contrib import messages
from django.db import transaction
from django.db.models import Exists, OuterRef, Q
from django.utils import timezone
from django.http import FileResponse, Http404, HttpResponseForbidden, JsonResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.urls import reverse
from django.utils._os import safe_join
from django.views.decorators.http import require_http_methods

from api.models import (
    AppUser,
    Assignment,
    CurriculumQuestion,
    CurriculumQuestionAttempt,
    CurriculumUnitAttempt,
    Grade,
    LessonType,
    Question,
    StudentAnswer,
    StudentProfile,
    SubLesson,
    SubLessonTypeMaster,
    Unit,
)


SESSION_USER_ID = 'ui_user_id'

CURRICULUM_ITEM_CONFIG = {
    'grade': {
        'model': Grade,
        'field': 'grade_name',
        'label': 'Grade',
    },
    'lesson': {
        'model': LessonType,
        'field': 'lesson_name',
        'label': 'Lesson',
    },
    'track': {
        'model': SubLesson,
        'field': 'sub_lesson_name',
        'label': 'Lesson Track',
    },
    'unit': {
        'model': Unit,
        'field': 'unit_name',
        'label': 'Unit',
    },
    'question': {
        'model': CurriculumQuestion,
        'field': 'question_text',
        'label': 'Question',
    },
}


def _get_current_user(request):
    user_id = request.session.get(SESSION_USER_ID)
    if not user_id:
        return None
    try:
        return AppUser.objects.get(id=user_id)
    except AppUser.DoesNotExist:
        return None


def _teacher_guard(request):
    user = _get_current_user(request)
    if not user:
        return None, redirect('ui-login')
    if user.role != 'teacher':
        return None, HttpResponseForbidden('Forbidden: teacher access required')
    return user, None


def _student_guard(request):
    user = _get_current_user(request)
    if not user:
        return None, redirect('ui-login')
    if user.role != 'student':
        return None, HttpResponseForbidden('Forbidden: student access required')
    return user, None


def _curriculum_name_exists(item_type, value, *, parent_id=None, item=None):
    normalized_value = value.strip()
    if not normalized_value:
        return False

    if item_type == 'grade':
        queryset = Grade.objects.filter(grade_name__iexact=normalized_value)
    elif item_type == 'lesson':
        lesson_parent_id = parent_id if parent_id is not None else getattr(item, 'grade_id', None)
        queryset = LessonType.objects.filter(
            grade_id=lesson_parent_id,
            lesson_name__iexact=normalized_value,
        )
    elif item_type == 'unit':
        unit_parent_id = parent_id if parent_id is not None else getattr(item, 'sub_lesson_id', None)
        queryset = Unit.objects.filter(
            sub_lesson_id=unit_parent_id,
            unit_name__iexact=normalized_value,
        )
    elif item_type == 'question':
        question_parent_id = parent_id if parent_id is not None else getattr(item, 'unit_id', None)
        queryset = CurriculumQuestion.objects.filter(
            unit_id=question_parent_id,
            question_text__iexact=normalized_value,
        )
    elif item_type == 'track' and item is not None:
        queryset = SubLesson.objects.filter(lesson_type_id=item.lesson_type_id, sub_lesson_name__iexact=normalized_value)
    else:
        return False

    if item is not None:
        queryset = queryset.exclude(id=item.id)

    return queryset.exists()


def _question_order_exists(unit_id, order_value, *, item=None):
    if order_value in (None, ''):
        return False

    queryset = CurriculumQuestion.objects.filter(
        unit_id=unit_id,
        order=int(order_value),
    )
    if item is not None:
        queryset = queryset.exclude(id=item.id)
    return queryset.exists()


def _save_profile_photo(profile_photo):
    if not profile_photo:
        return ''

    photo_dir = os.path.join(settings.MEDIA_ROOT, 'student_profiles')
    os.makedirs(photo_dir, exist_ok=True)
    extension = os.path.splitext(profile_photo.name)[1] or '.jpg'
    filename = f'{uuid4().hex}{extension}'
    absolute_path = os.path.join(photo_dir, filename)
    with open(absolute_path, 'wb+') as destination:
        for chunk in profile_photo.chunks():
            destination.write(chunk)
    return f'student_profiles/{filename}'


def _delete_profile_photo(photo_path):
    if not photo_path:
        return
    absolute_path = os.path.join(settings.MEDIA_ROOT, photo_path)
    if os.path.exists(absolute_path):
        os.remove(absolute_path)


def serve_media(request, path):
    try:
        file_path = safe_join(settings.MEDIA_ROOT, path)
    except ValueError as exc:
        raise Http404('Invalid media path') from exc

    if not file_path or not os.path.exists(file_path):
        raise Http404('Media file not found')

    return FileResponse(open(file_path, 'rb'))


def home(request):
    user = _get_current_user(request)
    if not user:
        return redirect('ui-login')
    if user.role == 'teacher':
        return redirect('ui-teacher-dashboard')
    if user.role == 'student':
        return redirect('ui-student-assignments')
    return redirect('ui-login')


@require_http_methods(['GET', 'POST'])
def login_view(request):
    if request.method == 'POST':
        email = request.POST.get('email', '').strip()
        password = request.POST.get('password', '')

        try:
            user = AppUser.objects.get(email=email)
        except AppUser.DoesNotExist:
            user = None

        if user and bcrypt.checkpw(password.encode('utf-8'), user.password.encode('utf-8')):
            request.session[SESSION_USER_ID] = user.id
            if user.role == 'teacher':
                return redirect('ui-teacher-dashboard')
            if user.role == 'student':
                return redirect('ui-student-assignments')
        else:
            messages.error(request, 'Invalid credentials')

    return render(request, 'ui/login.html')


def logout_view(request):
    request.session.flush()
    return redirect('ui-login')


def teacher_dashboard(request):
    user, response = _teacher_guard(request)
    if response:
        return response

    grades = Grade.objects.prefetch_related('lesson_types').order_by('id')
    students = StudentProfile.objects.select_related('user', 'grade').order_by('user__name')
    total_lessons = sum(grade.lesson_types.count() for grade in grades)

    return render(
        request,
        'ui/teacher_dashboard.html',
        {
            'current_user': user,
            'students': students,
            'grades': grades,
            'total_lessons': total_lessons,
        },
    )


@require_http_methods(['GET', 'POST'])
def teacher_curriculum(request):
    user, response = _teacher_guard(request)
    if response:
        return response

    active_tab = request.GET.get('tab', 'grade-panel').strip() or 'grade-panel'

    if request.method == 'POST':
        action = request.POST.get('action', '').strip()
        name = request.POST.get('name', '').strip()
        parent_id = request.POST.get('parent_id', '').strip()
        question_text = request.POST.get('question_text', '').strip()
        answer_text = request.POST.get('answer_text', '').strip()
        question_order = request.POST.get('order', '').strip()
        sub_lesson_type_ids = request.POST.getlist('sub_lesson_type_ids')
        active_tab = request.POST.get('active_tab', 'grade-panel').strip() or 'grade-panel'

        try:
            with transaction.atomic():
                if action == 'add_grade':
                    if not name:
                        messages.error(request, 'Grade name is required.')
                    elif _curriculum_name_exists('grade', name):
                        messages.error(request, 'This grade name already exists.')
                    else:
                        Grade.objects.create(grade_name=name)
                        messages.success(request, 'Grade added successfully.')
                elif action == 'add_lesson':
                    if not name or not parent_id:
                        messages.error(request, 'Lesson name and grade are required.')
                    elif _curriculum_name_exists('lesson', name, parent_id=int(parent_id)):
                        messages.error(request, 'This lesson name already exists for the selected grade.')
                    else:
                        lesson = LessonType.objects.create(grade_id=int(parent_id), lesson_name=name)
                        selected_types = list(
                            SubLessonTypeMaster.objects.filter(id__in=sub_lesson_type_ids).order_by('id')
                        )
                        SubLesson.objects.bulk_create(
                            [
                                SubLesson(
                                    lesson_type_id=lesson.id,
                                    sub_lesson_type_master_id=item.id,
                                    sub_lesson_name=item.type_name,
                                )
                                for item in selected_types
                            ]
                        )
                        if selected_types:
                            messages.success(request, f'Lesson added with {len(selected_types)} selected tracks.')
                        else:
                            messages.success(request, 'Lesson added successfully.')
                elif action == 'add_unit':
                    if not name or not parent_id:
                        messages.error(request, 'Unit name and lesson track are required.')
                    elif _curriculum_name_exists('unit', name, parent_id=int(parent_id)):
                        messages.error(request, 'This unit name already exists for the selected track.')
                    else:
                        Unit.objects.create(sub_lesson_id=int(parent_id), unit_name=name)
                        messages.success(request, 'Unit added successfully.')
                elif action == 'add_question':
                    if not question_text or not answer_text or not parent_id:
                        messages.error(request, 'Question text, answer, and unit are required.')
                    elif question_order and (not question_order.isdigit() or int(question_order) < 1):
                        messages.error(request, 'Order must be a positive number.')
                    elif _question_order_exists(int(parent_id), question_order):
                        messages.error(request, 'Order must be unique for the selected unit.')
                    else:
                        CurriculumQuestion.objects.create(
                            unit_id=int(parent_id),
                            question_text=question_text,
                            answer_text=answer_text,
                            order=int(question_order) if question_order else None,
                        )
                        messages.success(request, 'Question added successfully.')
                else:
                    messages.error(request, 'Unknown curriculum action.')
        except Exception as exc:
            messages.error(request, f'Unable to save curriculum item: {exc}')

        return redirect(f"{reverse('ui-teacher-curriculum')}?tab={active_tab}")

    grades = Grade.objects.prefetch_related(
        'lesson_types__sub_lessons__units__curriculum_questions'
    ).order_by('id')
    lessons = LessonType.objects.select_related('grade').order_by('grade_id', 'id')
    sub_lessons = SubLesson.objects.select_related('lesson_type__grade').order_by('lesson_type_id', 'id')
    units = Unit.objects.select_related('sub_lesson__lesson_type__grade').order_by('sub_lesson_id', 'id')
    sub_lesson_type_master = SubLessonTypeMaster.objects.order_by('id')

    return render(
        request,
        'ui/teacher_curriculum.html',
        {
            'current_user': user,
            'grades': grades,
            'lessons': lessons,
            'sub_lessons': sub_lessons,
            'units': units,
            'sub_lesson_type_master': sub_lesson_type_master,
            'active_tab': active_tab,
        },
    )


def teacher_students(request):
    user, response = _teacher_guard(request)
    if response:
        return response

    students = StudentProfile.objects.select_related('user', 'grade').order_by('user__name')
    return render(
        request,
        'ui/teacher_students.html',
        {
            'current_user': user,
            'students': students,
        },
    )


@require_http_methods(['GET', 'POST'])
def teacher_edit_curriculum_item(request, item_type, item_id):
    user, response = _teacher_guard(request)
    if response:
        return response

    config = CURRICULUM_ITEM_CONFIG.get(item_type)
    if not config:
        raise Http404('Unknown curriculum item type')

    item = get_object_or_404(config['model'], id=item_id)
    field_name = config['field']
    label = config['label']

    if request.method == 'POST':
        if item_type == 'question':
            value = request.POST.get('value', '').strip()
            answer = request.POST.get('answer', '').strip()
            order_value = request.POST.get('order', '').strip()
            if not value or not answer:
                messages.error(request, 'Question text and answer are required.')
            elif order_value and (not order_value.isdigit() or int(order_value) < 1):
                messages.error(request, 'Order must be a positive number.')
            elif _question_order_exists(item.unit_id, order_value, item=item):
                messages.error(request, 'Order must be unique for the selected unit.')
            else:
                item.question_text = value
                item.answer_text = answer
                item.order = int(order_value) if order_value else None
                item.save(update_fields=['question_text', 'answer_text', 'order'])
                messages.success(request, f'{label} updated successfully.')
                return redirect('ui-teacher-curriculum')
        else:
            value = request.POST.get('value', '').strip()
            if not value:
                messages.error(request, f'{label} value is required.')
            elif (
                (item_type == 'grade' and _curriculum_name_exists('grade', value, item=item)) or
                (item_type == 'lesson' and _curriculum_name_exists('lesson', value, parent_id=item.grade_id, item=item)) or
                (item_type == 'unit' and _curriculum_name_exists('unit', value, parent_id=item.sub_lesson_id, item=item)) or
                (item_type == 'track' and _curriculum_name_exists('track', value, item=item))
            ):
                messages.error(request, f'This {label.lower()} name already exists.')
            else:
                setattr(item, field_name, value)
                item.save(update_fields=[field_name])
                messages.success(request, f'{label} updated successfully.')
                return redirect('ui-teacher-curriculum')

    return render(
        request,
        'ui/teacher_edit_curriculum_item.html',
        {
            'current_user': user,
            'item': item,
            'item_label': label,
            'item_value': getattr(item, field_name),
            'item_answer': item.answer_text if item_type == 'question' else '',
            'item_order': item.order if item_type == 'question' else '',
            'item_type': item_type,
        },
    )


@require_http_methods(['POST'])
def teacher_delete_curriculum_item(request, item_type, item_id):
    user, response = _teacher_guard(request)
    if response:
        return response

    config = CURRICULUM_ITEM_CONFIG.get(item_type)
    if not config:
        raise Http404('Unknown curriculum item type')

    item = get_object_or_404(config['model'], id=item_id)
    label = config['label']
    item.delete()
    messages.success(request, f'{label} deleted successfully.')
    return redirect('ui-teacher-curriculum')


@require_http_methods(['GET', 'POST'])
def teacher_add_student(request):
    user, response = _teacher_guard(request)
    if response:
        return response

    grades = Grade.objects.order_by('id')

    if request.method == 'POST':
        first_name = request.POST.get('first_name', '').strip()
        last_name = request.POST.get('last_name', '').strip()
        date_of_birth = request.POST.get('date_of_birth', '').strip()
        father_name = request.POST.get('father_name', '').strip()
        mother_name = request.POST.get('mother_name', '').strip()
        email = request.POST.get('email', '').strip().lower()
        contact = request.POST.get('contact', '').strip()
        password = request.POST.get('password', '').strip()
        grade_id = request.POST.get('grade_id', '').strip()
        profile_photo = request.FILES.get('profile_photo')

        if not first_name or not last_name or not father_name or not mother_name or not email or not contact or not password:
            messages.error(
                request,
                'First name, last name, father name, mother name, email, contact, and password are required.',
            )
        elif AppUser.objects.filter(email=email).exists():
            messages.error(request, 'A user with that email already exists.')
        else:
            photo_path = _save_profile_photo(profile_photo)

            hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
            with transaction.atomic():
                created_user = AppUser.objects.create(
                    name=f'{first_name} {last_name}'.strip(),
                    email=email,
                    password=hashed_password,
                    role='student',
                )
                StudentProfile.objects.create(
                    user=created_user,
                    grade_id=int(grade_id) if grade_id else None,
                    first_name=first_name,
                    last_name=last_name,
                    date_of_birth=date_of_birth or None,
                    father_name=father_name,
                    mother_name=mother_name,
                    contact=contact,
                    profile_photo=photo_path,
                )
            messages.success(request, 'Student onboarded successfully.')
            return redirect('ui-teacher-students')

    return render(
        request,
        'ui/teacher_add_student.html',
        {
            'current_user': user,
            'grades': grades,
        },
    )


@require_http_methods(['GET', 'POST'])
def teacher_edit_student(request, student_id):
    user, response = _teacher_guard(request)
    if response:
        return response

    profile = get_object_or_404(StudentProfile.objects.select_related('user', 'grade'), id=student_id)
    grades = Grade.objects.order_by('id')

    if request.method == 'POST':
        first_name = request.POST.get('first_name', '').strip()
        last_name = request.POST.get('last_name', '').strip()
        date_of_birth = request.POST.get('date_of_birth', '').strip()
        father_name = request.POST.get('father_name', '').strip()
        mother_name = request.POST.get('mother_name', '').strip()
        email = request.POST.get('email', '').strip().lower()
        contact = request.POST.get('contact', '').strip()
        password = request.POST.get('password', '').strip()
        grade_id = request.POST.get('grade_id', '').strip()
        profile_photo = request.FILES.get('profile_photo')

        if not first_name or not last_name or not father_name or not mother_name or not email or not contact:
            messages.error(
                request,
                'First name, last name, father name, mother name, email, and contact are required.',
            )
        elif AppUser.objects.exclude(id=profile.user_id).filter(email=email).exists():
            messages.error(request, 'A user with that email already exists.')
        else:
            with transaction.atomic():
                profile.user.name = f'{first_name} {last_name}'.strip()
                profile.user.email = email
                if password:
                    profile.user.password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
                profile.user.save(update_fields=['name', 'email', 'password'] if password else ['name', 'email'])

                if profile_photo:
                    _delete_profile_photo(profile.profile_photo)
                    profile.profile_photo = _save_profile_photo(profile_photo)

                profile.first_name = first_name
                profile.last_name = last_name
                profile.date_of_birth = date_of_birth or None
                profile.father_name = father_name
                profile.mother_name = mother_name
                profile.contact = contact
                new_grade_id = int(grade_id) if grade_id else None
                previous_grade_id = profile.grade_id

                if previous_grade_id != new_grade_id:
                    Assignment.objects.filter(student_id=profile.user_id).delete()

                profile.grade_id = new_grade_id
                profile.save()

            if previous_grade_id != new_grade_id:
                messages.success(request, 'Student updated successfully. Old assignments were cleared for the new grade.')
            else:
                messages.success(request, 'Student updated successfully.')
            return redirect('ui-teacher-students')

    return render(
        request,
        'ui/teacher_edit_student.html',
        {
            'current_user': user,
            'grades': grades,
            'profile': profile,
        },
    )


@require_http_methods(['POST'])
def teacher_delete_student(request, student_id):
    user, response = _teacher_guard(request)
    if response:
        return response

    profile = get_object_or_404(StudentProfile.objects.select_related('user'), id=student_id)
    with transaction.atomic():
        _delete_profile_photo(profile.profile_photo)
        profile.user.delete()

    messages.success(request, 'Student removed successfully.')
    return redirect('ui-teacher-students')


@require_http_methods(['GET', 'POST'])
def teacher_profile(request):
    user, response = _teacher_guard(request)
    if response:
        return response

    if request.method == 'POST':
        name = request.POST.get('name', '').strip()
        email = request.POST.get('email', '').strip().lower()
        current_password = request.POST.get('current_password', '')
        new_password = request.POST.get('new_password', '')
        confirm_password = request.POST.get('confirm_password', '')

        if not name or not email:
            messages.error(request, 'Name and email are required.')
        elif AppUser.objects.exclude(id=user.id).filter(email=email).exists():
            messages.error(request, 'A user with that email already exists.')
        elif new_password or confirm_password or current_password:
            if not current_password:
                messages.error(request, 'Current password is required to set a new password.')
            elif not bcrypt.checkpw(current_password.encode('utf-8'), user.password.encode('utf-8')):
                messages.error(request, 'Current password is incorrect.')
            elif not new_password:
                messages.error(request, 'New password is required.')
            elif new_password != confirm_password:
                messages.error(request, 'New password and confirm password must match.')
            else:
                user.name = name
                user.email = email
                user.password = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
                user.save(update_fields=['name', 'email', 'password'])
                messages.success(request, 'Profile and password updated successfully.')
                return redirect('ui-teacher-profile')
        else:
            user.name = name
            user.email = email
            user.save(update_fields=['name', 'email'])
            messages.success(request, 'Profile updated successfully.')
            return redirect('ui-teacher-profile')

    return render(
        request,
        'ui/teacher_profile.html',
        {
            'current_user': user,
        },
    )


@require_http_methods(['GET', 'POST'])
def teacher_create_assignment(request):
    user, response = _teacher_guard(request)
    if response:
        return response

    students = StudentProfile.objects.select_related('user', 'grade').order_by('user__name')
    grades = Grade.objects.prefetch_related('lesson_types').order_by('id')
    source = request.POST if request.method == 'POST' else request.GET
    selected_student_id = source.get('student_id', '').strip()
    selected_grade_id = source.get('grade_id', '').strip()
    selected_lesson_ids = [value.strip() for value in source.getlist('lesson_ids') if value.strip()]
    assignment_kind = source.get('assignment_kind', Assignment.KIND_HOMEWORK).strip() or Assignment.KIND_HOMEWORK
    today_value = timezone.localdate().isoformat()
    available_on = source.get('available_on', '').strip() or today_value
    selected_student = next((profile for profile in students if str(profile.user_id) == str(selected_student_id)), None)
    latest_assignment = None
    summary_lessons = []

    if selected_student_id:
        latest_assignment = (
            Assignment.objects.filter(student_id=int(selected_student_id))
            .select_related('lesson__grade', 'teacher')
            .order_by('-assigned_date', '-id')
            .first()
        )

    if selected_student_id and not selected_grade_id:
        if latest_assignment:
            selected_grade_id = str(latest_assignment.lesson.grade_id)
        elif selected_student and selected_student.grade_id:
            selected_grade_id = str(selected_student.grade_id)

    if request.method == 'GET' and selected_student_id and selected_grade_id and not selected_lesson_ids:
        selected_lesson_ids = [
            str(lesson_id)
            for lesson_id in Assignment.objects.filter(
                student_id=int(selected_student_id),
                lesson__grade_id=int(selected_grade_id),
            ).order_by('lesson_id').values_list('lesson_id', flat=True).distinct()
        ]

    lessons = []
    if selected_grade_id:
        lessons = list(
            LessonType.objects.select_related('grade').prefetch_related(
                'sub_lessons__units__curriculum_questions'
            ).filter(grade_id=selected_grade_id).order_by('grade_id', 'id')
        )

    if request.method == 'POST':
        if assignment_kind != Assignment.KIND_CLASSROOM:
            available_on = today_value

        if not selected_student_id or not selected_grade_id or not selected_lesson_ids:
            messages.error(request, 'Student, grade, and at least one lesson are required before assigning.')
        elif assignment_kind == Assignment.KIND_CLASSROOM and not available_on:
            messages.error(request, 'Classroom lesson requires an availability date.')
        else:
            with transaction.atomic():
                selected_lesson_ids_int = [int(lesson_id) for lesson_id in selected_lesson_ids]
                removed_previous_grade_count = Assignment.objects.filter(
                    student_id=int(selected_student_id),
                ).exclude(
                    lesson__grade_id=int(selected_grade_id),
                ).delete()[0]
                replaced_count = Assignment.objects.filter(
                    student_id=int(selected_student_id),
                    lesson__grade_id=int(selected_grade_id),
                ).delete()[0]
                assignments_to_create = []
                for lesson_id in selected_lesson_ids_int:
                    assignments_to_create.append(
                        Assignment(
                            teacher_id=user.id,
                            student_id=int(selected_student_id),
                            lesson_id=lesson_id,
                            assigned_date=timezone.now(),
                            assignment_kind=assignment_kind,
                            available_on=available_on or None,
                        )
                    )
                Assignment.objects.bulk_create(assignments_to_create)
            if removed_previous_grade_count and replaced_count:
                messages.success(
                    request,
                    f'{len(selected_lesson_ids_int)} lesson(s) assigned successfully. Previous-grade lessons were removed and matching lesson assignments were replaced.',
                )
            elif removed_previous_grade_count:
                messages.success(
                    request,
                    f'{len(selected_lesson_ids_int)} lesson(s) assigned successfully. Previous-grade lessons were removed for this student.',
                )
            elif replaced_count:
                messages.success(
                    request,
                    f'{len(selected_lesson_ids_int)} lesson(s) assigned successfully. Existing lesson assignments were replaced.',
                )
            else:
                messages.success(request, f'{len(selected_lesson_ids_int)} lesson(s) assigned successfully.')
            redirect_url = f"{reverse('ui-teacher-create-assignment')}?student_id={selected_student_id}&grade_id={selected_grade_id}"
            return redirect(redirect_url)

    lesson_options = []
    for lesson in lessons:
        sub_lesson_items = []
        unit_count = 0
        question_count = 0

        for sub_lesson in lesson.sub_lessons.all():
            units_for_track = []
            for unit in sub_lesson.units.all():
                question_items = [
                    {
                        'id': curriculum_question.id,
                        'order': curriculum_question.order,
                        'text': curriculum_question.question_text,
                        'answer': curriculum_question.answer_text or '',
                    }
                    for curriculum_question in unit.curriculum_questions.all().order_by('order', 'id')
                ]
                question_count += len(question_items)
                units_for_track.append(
                    {
                        'id': unit.id,
                        'name': unit.unit_name,
                        'questions': question_items,
                    }
                )
            unit_count += len(units_for_track)
            sub_lesson_items.append(
                {
                    'id': sub_lesson.id,
                    'name': sub_lesson.sub_lesson_name,
                    'units': units_for_track,
                }
            )

        lesson_options.append(
            {
                'id': lesson.id,
                'grade_id': lesson.grade_id,
                'grade_name': lesson.grade.grade_name if getattr(lesson, 'grade', None) else '',
                'name': lesson.lesson_name,
                'sub_lessons': sub_lesson_items,
                'sub_lesson_count': len(sub_lesson_items),
                'unit_count': unit_count,
                'question_count': question_count,
            }
        )

    selected_grade = next((grade for grade in grades if str(grade.id) == str(selected_grade_id)), None)
    selected_lessons = [item for item in lesson_options if str(item['id']) in selected_lesson_ids]

    if latest_assignment:
        summary_lessons = list(
            LessonType.objects.filter(
                assignments__student_id=int(selected_student_id),
                grade_id=latest_assignment.lesson.grade_id,
            )
            .order_by('id')
            .distinct()
        )

    summary_grade_name = latest_assignment.lesson.grade.grade_name if latest_assignment else (selected_student.grade.grade_name if selected_student and selected_student.grade else None)
    summary_assignment_kind = latest_assignment.assignment_kind if latest_assignment else assignment_kind
    summary_available_on = (
        latest_assignment.available_on.isoformat()
        if latest_assignment and latest_assignment.available_on
        else available_on
    )

    return render(
        request,
        'ui/teacher_create_assignment.html',
        {
            'current_user': user,
            'students': students,
            'grades': grades,
            'lesson_options': lesson_options,
            'selected_student_id': str(selected_student_id),
            'selected_grade_id': str(selected_grade_id),
            'selected_lesson_ids': selected_lesson_ids,
            'assignment_kind': assignment_kind,
            'available_on': available_on,
            'today_value': today_value,
            'selected_student': selected_student,
            'selected_grade': selected_grade,
            'selected_lessons': selected_lessons,
            'summary_grade_name': summary_grade_name,
            'summary_assignment_kind': summary_assignment_kind,
            'summary_available_on': summary_available_on,
            'summary_lessons': summary_lessons,
        },
    )


def teacher_results(request):
    user, response = _teacher_guard(request)
    if response:
        return response

    students = StudentProfile.objects.select_related('user', 'grade').order_by('user__name')
    selected_student_id = request.GET.get('student_id', '').strip()
    selected_assignment_id = request.GET.get('assignment_id', '').strip()

    assignments = []
    selected_result = None

    if selected_student_id:
        selected_profile = StudentProfile.objects.select_related('grade').filter(user_id=selected_student_id).first()
        submitted_answers = StudentAnswer.objects.filter(
            question__assignment_id=OuterRef('pk'),
            student_id=selected_student_id,
        )
        assignments_queryset = Assignment.objects.filter(student_id=selected_student_id)
        if selected_profile and selected_profile.grade_id:
            assignments_queryset = assignments_queryset.filter(lesson__grade_id=selected_profile.grade_id)
        assignments = list(
            assignments_queryset
            .select_related('lesson__grade', 'teacher')
            .annotate(is_submitted=Exists(submitted_answers))
            .order_by('-assigned_date')
        )

    if selected_assignment_id:
        assignment_queryset = Assignment.objects.select_related('student', 'lesson__grade').prefetch_related('questions__answers')
        if selected_student_id:
            assignment_queryset = assignment_queryset.filter(student_id=selected_student_id)
        selected_profile = StudentProfile.objects.select_related('grade').filter(user_id=selected_student_id).first()
        if selected_profile and selected_profile.grade_id:
            assignment_queryset = assignment_queryset.filter(lesson__grade_id=selected_profile.grade_id)
        assignment = get_object_or_404(
            assignment_queryset,
            id=selected_assignment_id,
        )
        questions = []
        correct = 0
        for question in assignment.questions.all().order_by('id'):
            answer = next((item for item in question.answers.all() if item.student_id == assignment.student_id), None)
            if answer and answer.is_correct:
                correct += 1
            questions.append(
                {
                    'question_text': question.question_text,
                    'student_answer': answer.student_answer if answer else '',
                    'correct_answer': question.correct_answer,
                    'is_correct': bool(answer and answer.is_correct),
                }
            )
        total = len(questions)
        selected_result = {
            'assignment': assignment,
            'questions': questions,
            'correct': correct,
            'total': total,
            'percentage': round((correct / total) * 100) if total else 0,
        }

    return render(
        request,
        'ui/teacher_results.html',
        {
            'current_user': user,
            'students': students,
            'selected_student_id': selected_student_id,
            'assignments': assignments,
            'selected_assignment_id': selected_assignment_id,
            'selected_result': selected_result,
        },
    )


def _student_available_assignments(user_id, grade_id=None, *, category='all'):
    today = timezone.localdate()
    submitted_answers = StudentAnswer.objects.filter(
        question__assignment_id=OuterRef('pk'),
        student_id=user_id,
    )
    assignments_queryset = Assignment.objects.filter(student_id=user_id)

    if category == Assignment.KIND_HOMEWORK:
        assignments_queryset = assignments_queryset.filter(assignment_kind=Assignment.KIND_HOMEWORK)
    elif category == Assignment.KIND_CLASSROOM:
        assignments_queryset = assignments_queryset.filter(
            assignment_kind=Assignment.KIND_CLASSROOM,
            available_on=today,
        )
    else:
        assignments_queryset = assignments_queryset.filter(
            Q(assignment_kind=Assignment.KIND_HOMEWORK) |
            Q(assignment_kind=Assignment.KIND_CLASSROOM, available_on=today)
        )

    if grade_id:
        assignments_queryset = assignments_queryset.filter(lesson__grade_id=grade_id)

    return list(
        assignments_queryset
        .select_related('lesson__grade', 'teacher')
        .prefetch_related('lesson__sub_lessons__units__curriculum_questions')
        .annotate(is_submitted=Exists(submitted_answers))
        .order_by('-assigned_date', '-id')
    )


def _build_student_lesson_tracks(lesson):
    practice_mode_map = {
        'listening abacus': 'listening',
        'listening anzan': 'listening',
        'flash anzan': 'flash',
        'multiplication abacus': 'multiplication',
        'multiplication anzan': 'multiplication',
        'division abacus': 'division',
        'division anzan': 'division',
    }

    lesson_tracks = []
    for sub_lesson in lesson.sub_lessons.all().order_by('id'):
        track_name = (
            sub_lesson.sub_lesson_type_master.type_name
            if sub_lesson.sub_lesson_type_master_id and sub_lesson.sub_lesson_type_master
            else sub_lesson.sub_lesson_name
        )
        practice_mode = practice_mode_map.get(track_name.strip().lower(), 'default')
        units = []
        for unit in sub_lesson.units.all().order_by('id'):
            units.append(
                {
                    'id': unit.id,
                    'unit_name': unit.unit_name,
                    'track_name': track_name,
                    'practice_mode': practice_mode,
                    'is_audio_mode': practice_mode in {'listening', 'multiplication', 'division'},
                    'questions': [
                        {
                            'id': question.id,
                            'question_text': question.question_text,
                            'answer_text': question.answer_text or '',
                        }
                        for question in unit.curriculum_questions.all().order_by('order', 'id')
                    ],
                }
            )
        lesson_tracks.append(
            {
                'id': sub_lesson.id,
                'name': track_name,
                'practice_mode': practice_mode,
                'units': units,
            }
        )
    return lesson_tracks


def _populate_student_assignment_totals(assignments):
    for assignment in assignments:
        total_units = 0
        total_questions = 0
        for sub_lesson in assignment.lesson.sub_lessons.all():
            units = list(sub_lesson.units.all())
            total_units += len(units)
            total_questions += sum(unit.curriculum_questions.count() for unit in units)
        assignment.total_units = total_units
        assignment.total_curriculum_questions = total_questions


def _serialize_unit_attempts(student_id, lesson_tracks):
    unit_ids = [
        unit['id']
        for track in lesson_tracks
        for unit in track['units']
    ]
    if not unit_ids:
        return {}

    attempts = (
        CurriculumUnitAttempt.objects
        .filter(student_id=student_id, unit_id__in=unit_ids)
        .prefetch_related('question_attempts')
    )

    attempt_map = {}
    for attempt in attempts:
        question_statuses = {
            item.curriculum_question_id: {
                'status': 'correct' if item.is_correct else 'incorrect',
                'student_answer': item.student_answer,
            }
            for item in attempt.question_attempts.all()
        }
        attempt_map[attempt.unit_id] = {
            'status': attempt.status,
            'elapsed_seconds': attempt.elapsed_seconds,
            'correct_count': attempt.correct_count,
            'wrong_count': attempt.wrong_count,
            'completed_at': attempt.completed_at.isoformat() if attempt.completed_at else None,
            'question_statuses': question_statuses,
        }
    return attempt_map


def student_dashboard(request):
    user, response = _student_guard(request)
    if response:
        return response

    profile = StudentProfile.objects.select_related('grade').filter(user_id=user.id).first()
    assignments = _student_available_assignments(
        user.id,
        profile.grade_id if profile and profile.grade_id else None,
    )
    _populate_student_assignment_totals(assignments)
    homework_assignments = [assignment for assignment in assignments if assignment.assignment_kind == Assignment.KIND_HOMEWORK]
    classroom_assignments = [assignment for assignment in assignments if assignment.assignment_kind == Assignment.KIND_CLASSROOM]

    total_assignments = len(assignments)
    submitted_count = sum(1 for assignment in assignments if assignment.is_submitted)
    pending_count = total_assignments - submitted_count

    latest_assignment = assignments[0] if assignments else None
    dashboard_grade_name = None
    if profile and profile.grade:
        dashboard_grade_name = profile.grade.grade_name
    elif latest_assignment and latest_assignment.lesson and latest_assignment.lesson.grade:
        dashboard_grade_name = latest_assignment.lesson.grade.grade_name

    return render(
        request,
        'ui/student_dashboard.html',
        {
            'current_user': user,
            'student_profile': profile,
            'assignments': assignments[:5],
            'total_assignments': total_assignments,
            'submitted_count': submitted_count,
            'pending_count': pending_count,
            'latest_assignment': latest_assignment,
            'homework_count': len(homework_assignments),
            'classroom_count': len(classroom_assignments),
            'dashboard_grade_name': dashboard_grade_name,
        },
    )


@require_http_methods(['GET', 'POST'])
def student_profile(request):
    user, response = _student_guard(request)
    if response:
        return response

    profile = get_object_or_404(StudentProfile.objects.select_related('grade'), user_id=user.id)
    assignments = _student_available_assignments(
        user.id,
        profile.grade_id if profile and profile.grade_id else None,
    )
    total_assignments = len(assignments)
    submitted_count = sum(1 for assignment in assignments if assignment.is_submitted)
    pending_count = total_assignments - submitted_count
    latest_assignment = assignments[0] if assignments else None
    dashboard_grade_name = '-'
    if profile.grade:
        dashboard_grade_name = profile.grade.grade_name
    elif latest_assignment and latest_assignment.lesson and latest_assignment.lesson.grade:
        dashboard_grade_name = latest_assignment.lesson.grade.grade_name
    is_editing = request.GET.get('edit') == '1' or request.method == 'POST'

    if request.method == 'POST':
        first_name = request.POST.get('first_name', '').strip()
        last_name = request.POST.get('last_name', '').strip()
        date_of_birth = request.POST.get('date_of_birth', '').strip()
        father_name = request.POST.get('father_name', '').strip()
        mother_name = request.POST.get('mother_name', '').strip()
        email = request.POST.get('email', '').strip().lower()
        contact = request.POST.get('contact', '').strip()
        profile_photo = request.FILES.get('profile_photo')
        current_password = request.POST.get('current_password', '')
        new_password = request.POST.get('new_password', '')
        confirm_password = request.POST.get('confirm_password', '')

        if not first_name or not last_name or not father_name or not mother_name or not email or not contact:
            messages.error(
                request,
                'First name, last name, father name, mother name, email, and contact are required.',
            )
        elif AppUser.objects.exclude(id=user.id).filter(email=email).exists():
            messages.error(request, 'A user with that email already exists.')
        elif new_password or confirm_password or current_password:
            if not current_password:
                messages.error(request, 'Current password is required to set a new password.')
            elif not bcrypt.checkpw(current_password.encode('utf-8'), user.password.encode('utf-8')):
                messages.error(request, 'Current password is incorrect.')
            elif not new_password:
                messages.error(request, 'New password is required.')
            elif new_password != confirm_password:
                messages.error(request, 'New password and confirm password must match.')
            else:
                with transaction.atomic():
                    user.name = f'{first_name} {last_name}'.strip()
                    user.email = email
                    user.password = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
                    user.save(update_fields=['name', 'email', 'password'])

                    if profile_photo:
                        _delete_profile_photo(profile.profile_photo)
                        profile.profile_photo = _save_profile_photo(profile_photo)

                    profile.first_name = first_name
                    profile.last_name = last_name
                    profile.date_of_birth = date_of_birth or None
                    profile.father_name = father_name
                    profile.mother_name = mother_name
                    profile.contact = contact
                    profile.save()

                messages.success(request, 'Profile and password updated successfully.')
                return redirect('ui-student-profile')
        else:
            with transaction.atomic():
                user.name = f'{first_name} {last_name}'.strip()
                user.email = email
                user.save(update_fields=['name', 'email'])

                if profile_photo:
                    _delete_profile_photo(profile.profile_photo)
                    profile.profile_photo = _save_profile_photo(profile_photo)

                profile.first_name = first_name
                profile.last_name = last_name
                profile.date_of_birth = date_of_birth or None
                profile.father_name = father_name
                profile.mother_name = mother_name
                profile.contact = contact
                profile.save()

            messages.success(request, 'Profile updated successfully.')
            return redirect('ui-student-profile')

    return render(
        request,
        'ui/student_profile.html',
        {
            'current_user': user,
            'student_profile': profile,
            'dashboard_grade_name': dashboard_grade_name,
            'total_assignments': total_assignments,
            'submitted_count': submitted_count,
            'pending_count': pending_count,
            'is_editing': is_editing,
        },
    )


def student_assignments(request):
    user, response = _student_guard(request)
    if response:
        return response

    profile = StudentProfile.objects.select_related('grade').filter(user_id=user.id).first()
    category = request.GET.get('category', 'all').strip().lower()
    if category not in {'all', Assignment.KIND_HOMEWORK, Assignment.KIND_CLASSROOM}:
        category = 'all'
    selected_assignment_id = request.GET.get('assignment_id', '').strip()
    assignments = _student_available_assignments(
        user.id,
        profile.grade_id if profile and profile.grade_id else None,
        category=category,
    )
    _populate_student_assignment_totals(assignments)

    selected_assignment = None
    lesson_tracks = []
    unit_attempt_map = {}
    if selected_assignment_id:
        selected_assignment_queryset = Assignment.objects.select_related('lesson__grade', 'teacher').prefetch_related(
            'questions__answers',
            'lesson__sub_lessons__sub_lesson_type_master',
            'lesson__sub_lessons__units__curriculum_questions',
        ).filter(
            student_id=user.id,
        )
        if profile and profile.grade_id:
            selected_assignment_queryset = selected_assignment_queryset.filter(lesson__grade_id=profile.grade_id)
        if category in {Assignment.KIND_HOMEWORK, Assignment.KIND_CLASSROOM}:
            selected_assignment_queryset = selected_assignment_queryset.filter(assignment_kind=category)
        selected_assignment = get_object_or_404(
            selected_assignment_queryset,
            id=selected_assignment_id,
        )
        lesson_tracks = _build_student_lesson_tracks(selected_assignment.lesson)
        unit_attempt_map = _serialize_unit_attempts(user.id, lesson_tracks)

    return render(
        request,
        'ui/student_assignments.html',
        {
            'current_user': user,
            'student_profile': profile,
            'assignments': assignments,
            'assignment_category': category,
            'selected_assignment_id': selected_assignment_id,
            'selected_assignment': selected_assignment,
            'lesson_tracks': lesson_tracks,
            'unit_attempt_map': unit_attempt_map,
        },
    )


@require_http_methods(['POST'])
def student_submit_unit_question(request):
    user, response = _student_guard(request)
    if response:
        return response

    unit_id = request.POST.get('unit_id', '').strip()
    question_id = request.POST.get('question_id', '').strip()
    student_answer = request.POST.get('student_answer', '')
    elapsed_seconds = request.POST.get('elapsed_seconds', '').strip()

    if not unit_id or not question_id:
        return JsonResponse({'message': 'unit_id and question_id are required.'}, status=400)

    if elapsed_seconds and (not elapsed_seconds.isdigit() or int(elapsed_seconds) < 0):
        return JsonResponse({'message': 'elapsed_seconds must be a non-negative number.'}, status=400)

    unit = get_object_or_404(Unit, id=unit_id)
    question = get_object_or_404(CurriculumQuestion, id=question_id, unit_id=unit.id)
    normalized_answer = (student_answer or '').strip()
    is_correct = normalized_answer.lower() == (question.answer_text or '').strip().lower()

    with transaction.atomic():
        attempt, created = CurriculumUnitAttempt.objects.get_or_create(
            student_id=user.id,
            unit_id=unit.id,
            defaults={
                'status': CurriculumUnitAttempt.STATUS_IN_PROGRESS,
                'elapsed_seconds': int(elapsed_seconds or '0'),
                'correct_count': 0,
                'wrong_count': 0,
                'created_at': timezone.now(),
                'updated_at': timezone.now(),
            },
        )
        if not created:
            attempt.elapsed_seconds = int(elapsed_seconds or attempt.elapsed_seconds or 0)
            attempt.updated_at = timezone.now()
            attempt.save(update_fields=['elapsed_seconds', 'updated_at'])

        question_attempt, qa_created = CurriculumQuestionAttempt.objects.get_or_create(
            unit_attempt_id=attempt.id,
            curriculum_question_id=question.id,
            defaults={
                'student_answer': normalized_answer,
                'is_correct': is_correct,
                'attempted_at': timezone.now(),
            },
        )
        if not qa_created:
            return JsonResponse({'message': 'This question was already attempted.'}, status=400)

        total_questions = unit.curriculum_questions.count()
        answered_attempts = list(attempt.question_attempts.all())
        correct_count = sum(1 for item in answered_attempts if item.is_correct)
        wrong_count = len(answered_attempts) - correct_count
        is_complete = len(answered_attempts) >= total_questions and total_questions > 0

        attempt.correct_count = correct_count
        attempt.wrong_count = wrong_count
        attempt.elapsed_seconds = int(elapsed_seconds or attempt.elapsed_seconds or 0)
        if is_complete:
            attempt.status = (
                CurriculumUnitAttempt.STATUS_PASSED
                if wrong_count <= 2
                else CurriculumUnitAttempt.STATUS_FAILED
            )
            attempt.completed_at = timezone.now()
        else:
            attempt.status = CurriculumUnitAttempt.STATUS_IN_PROGRESS
            attempt.completed_at = None
        attempt.updated_at = timezone.now()
        attempt.save(update_fields=['correct_count', 'wrong_count', 'elapsed_seconds', 'status', 'completed_at', 'updated_at'])

    return JsonResponse(
        {
            'question_id': question.id,
            'is_correct': is_correct,
            'status': 'correct' if is_correct else 'incorrect',
            'correct_count': attempt.correct_count,
            'wrong_count': attempt.wrong_count,
            'elapsed_seconds': attempt.elapsed_seconds,
            'is_complete': is_complete,
            'attempt_status': attempt.status,
            'pass': attempt.status == CurriculumUnitAttempt.STATUS_PASSED,
        }
    )
