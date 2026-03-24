import bcrypt
import jwt
from django.conf import settings
from django.db import transaction
from django.utils import timezone
from rest_framework import serializers

from .models import AppUser, StudentProfile


def build_token(user):
    payload = {
        'id': user.id,
        'email': user.email,
        'role': user.role,
        'name': user.name,
        'exp': timezone.now() + settings.JWT_EXPIRY,
    }
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.JWT_ALGORITHM)


def serialize_user(user):
    return {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role,
    }


class RegisterSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=120)
    email = serializers.EmailField(max_length=180)
    password = serializers.CharField(write_only=True)
    role = serializers.ChoiceField(choices=['teacher', 'student'])
    gradeId = serializers.IntegerField(required=False, allow_null=True)

    def validate(self, attrs):
        if attrs['role'] == 'student' and not attrs.get('gradeId'):
            raise serializers.ValidationError({'message': 'gradeId is required for student registration'})
        return attrs

    def create(self, validated_data):
        if AppUser.objects.filter(email=validated_data['email']).exists():
            raise serializers.ValidationError({'message': 'Email already registered'})

        hashed_password = bcrypt.hashpw(
            validated_data['password'].encode('utf-8'),
            bcrypt.gensalt(),
        ).decode('utf-8')

        with transaction.atomic():
            user = AppUser.objects.create(
                name=validated_data['name'],
                email=validated_data['email'],
                password=hashed_password,
                role=validated_data['role'],
            )
            if user.role == 'student':
                StudentProfile.objects.create(
                    user=user,
                    grade_id=validated_data.get('gradeId'),
                )

        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField(max_length=180)
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        try:
            user = AppUser.objects.get(email=attrs['email'])
        except AppUser.DoesNotExist as exc:
            raise serializers.ValidationError({'message': 'Invalid credentials'}) from exc

        if not bcrypt.checkpw(attrs['password'].encode('utf-8'), user.password.encode('utf-8')):
            raise serializers.ValidationError({'message': 'Invalid credentials'})

        attrs['user'] = user
        return attrs
