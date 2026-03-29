import jwt
from django.conf import settings
from rest_framework import exceptions
from rest_framework.authentication import BaseAuthentication, get_authorization_header

from .models import AppUser


class JWTAuthentication(BaseAuthentication):
    def authenticate(self, request):
        auth = get_authorization_header(request).split()
        if not auth:
            return None

        if auth[0].lower() != b'bearer' or len(auth) != 2:
            raise exceptions.AuthenticationFailed('Unauthorized: invalid token')

        token = auth[1].decode('utf-8')
        try:
            payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
        except jwt.PyJWTError as exc:
            raise exceptions.AuthenticationFailed('Unauthorized: invalid token') from exc

        user_id = payload.get('id')
        if not user_id:
            raise exceptions.AuthenticationFailed('Unauthorized: invalid token')

        try:
            user = AppUser.objects.get(id=user_id)
        except AppUser.DoesNotExist as exc:
            raise exceptions.AuthenticationFailed('Unauthorized: user not found') from exc

        return (user, token)
