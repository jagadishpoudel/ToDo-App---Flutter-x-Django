from rest_framework import serializers
from .models import Skill
from django.contrib.auth.models import User


class SkillSerializer(serializers.ModelSerializer):
    class Meta:
        model = Skill
        fields = ['id', 'name', 'skill', 'created_at']


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = ['username', 'email', 'password']
    
    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password']
        )
        return user


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
    
    def validate(self, data):
        from django.contrib.auth import authenticate
        user = authenticate(
            username=data['username'],
            password=data['password']
        )
        if not user:
            raise serializers.ValidationError('Invalid credentials')
        data['user'] = user
        return data
