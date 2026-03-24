from rest_framework.permissions import BasePermission


class IsAuthenticatedUser(BasePermission):
    message = 'Unauthorized: missing token'

    def has_permission(self, request, view):
        return bool(getattr(request, 'user', None))


class IsTeacher(BasePermission):
    message = 'Forbidden: insufficient permissions'

    def has_permission(self, request, view):
        user = getattr(request, 'user', None)
        return bool(user and user.role == 'teacher')


class IsStudent(BasePermission):
    message = 'Forbidden: insufficient permissions'

    def has_permission(self, request, view):
        user = getattr(request, 'user', None)
        return bool(user and user.role == 'student')
