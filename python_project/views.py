from django.shortcuts import render
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.authtoken.models import Token
from . import database
from rest_framework import status
from .models import Skill
from .serializers import SkillSerializer, RegisterSerializer, LoginSerializer
from django.contrib.auth.models import User

# Create your views here.
# Request Handler

def myapp(request):
    return render(request, "main.html", {'name': 'Jagadish Poudel'})


@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    """Register a new user"""
    try:
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'status': 'success',
                'message': 'User registered successfully',
                'token': token.key,
                'username': user.username
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    """Login user and return token"""
    try:
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data['user']
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'status': 'success',
                'message': 'Login successful',
                'token': token.key,
                'username': user.username
            }, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def getData(request):
    try:
        if request.method == 'GET':
            # Fetch all skills for the current user
            skills = Skill.objects.filter(user=request.user)
            serializer = SkillSerializer(skills, many=True)
            
            # Format response to match old format with numeric string keys
            data = {}
            for idx, skill in enumerate(serializer.data, start=1):
                data[str(idx)] = {
                    'id': skill['id'],
                    'name': skill['name'],
                    'skill': skill['skill']
                }
            return Response(data, status=status.HTTP_200_OK)
        
        elif request.method == 'POST':
            data = request.data
            
            # Check if this is a new skill submission (has 'name' and 'skill' fields)
            if 'name' in data and 'skill' in data:
                name = data.get('name')
                skill = data.get('skill')
                
                # Validate input
                if not name or not skill:
                    return Response(
                        {'error': 'Name and skill fields are required'},
                        status=status.HTTP_400_BAD_REQUEST
                    )
                
                # Save to database with current user
                new_skill = Skill.objects.create(
                    user=request.user,
                    name=name,
                    skill=skill
                )
                
                response_data = {
                    'id': new_skill.id,
                    'skill': {
                        'name': new_skill.name,
                        'skill': new_skill.skill
                    },
                    'status': 'success',
                    'message': 'Skill added successfully'
                }
                return Response(response_data, status=status.HTTP_201_CREATED)
            
            # Otherwise, treat it as a number-based lookup (legacy support)
            number = data.get('number')
            if number:
                try:
                    # Try to fetch from database by ID
                    skill_id = int(number)
                    skill = Skill.objects.get(id=skill_id, user=request.user)
                    response_data = {
                        'skill': {
                            'name': skill.name,
                            'skill': skill.skill
                        },
                        'status': 'success'
                    }
                    return Response(response_data, status=status.HTTP_200_OK)
                except (Skill.DoesNotExist, ValueError):
                    # Fallback to in-memory dictionary if exists
                    try:
                        response_data = {'skill': database.mySkills[number], 'status': 'success'}
                        return Response(response_data, status=status.HTTP_200_OK)
                    except:
                        response_data = {'message': 'Skill not found', 'status': 'error'}
                        return Response(response_data, status=status.HTTP_404_NOT_FOUND)
            
            return Response(
                {'error': 'Invalid request data'},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def updateSkill(request, skill_id):
    """Update a skill by ID"""
    try:
        skill = Skill.objects.get(id=skill_id, user=request.user)
    except Skill.DoesNotExist:
        return Response(
            {'error': 'Skill not found or you do not have permission'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    try:
        data = request.data
        
        # Update name if provided
        if 'name' in data:
            skill.name = data.get('name')
        
        # Update skill if provided
        if 'skill' in data:
            skill.skill = data.get('skill')
        
        # Validate input
        if not skill.name or not skill.skill:
            return Response(
                {'error': 'Name and skill fields are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        skill.save()
        
        response_data = {
            'id': skill.id,
            'name': skill.name,
            'skill': skill.skill,
            'status': 'success',
            'message': 'Skill updated successfully'
        }
        return Response(response_data, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def deleteSkill(request, skill_id):
    """Delete a skill by ID"""
    try:
        skill = Skill.objects.get(id=skill_id, user=request.user)
    except Skill.DoesNotExist:
        return Response(
            {'error': 'Skill not found or you do not have permission'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    try:
        skill_name = skill.name
        skill.delete()
        
        response_data = {
            'status': 'success',
            'message': f'Skill "{skill_name}" deleted successfully'
        }
        return Response(response_data, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


def admin_dashboard(request):
    """Admin dashboard to view all users and their skills"""
    if not request.user.is_authenticated or not request.user.is_staff:
        return render(request, 'admin.html', {'error': 'Unauthorized access. Admin only.'})
    
    users = User.objects.all()
    context = {
        'users': users,
        'total_users': users.count(),
        'total_skills': Skill.objects.count(),
    }
    return render(request, 'admin.html', context)


def delete_user_admin(request, user_id):
    """Delete a user and all their skills"""
    if not request.user.is_authenticated or not request.user.is_staff:
        return render(request, 'admin.html', {'error': 'Unauthorized access. Admin only.'})
    
    try:
        user = User.objects.get(id=user_id)
        username = user.username
        user.delete()
        users = User.objects.all()
        context = {
            'users': users,
            'total_users': users.count(),
            'total_skills': Skill.objects.count(),
            'success': f'User "{username}" deleted successfully'
        }
        return render(request, 'admin.html', context)
    except User.DoesNotExist:
        users = User.objects.all()
        context = {
            'users': users,
            'error': 'User not found'
        }
        return render(request, 'admin.html', context)
    except Exception as e:
        users = User.objects.all()
        context = {
            'users': users,
            'error': str(e)
        }
        return render(request, 'admin.html', context)


def delete_skill_admin(request, skill_id):
    """Delete a skill from admin dashboard"""
    if not request.user.is_authenticated or not request.user.is_staff:
        return render(request, 'admin.html', {'error': 'Unauthorized access. Admin only.'})
    
    try:
        skill = Skill.objects.get(id=skill_id)
        skill_name = skill.name
        skill.delete()
        users = User.objects.all()
        context = {
            'users': users,
            'total_users': users.count(),
            'total_skills': Skill.objects.count(),
            'success': f'Skill "{skill_name}" deleted successfully'
        }
        return render(request, 'admin.html', context)
    except Skill.DoesNotExist:
        users = User.objects.all()
        context = {
            'users': users,
            'error': 'Skill not found'
        }
        return render(request, 'admin.html', context)
    except Exception as e:
        users = User.objects.all()
        context = {
            'users': users,
            'error': str(e)
        }
        return render(request, 'admin.html', context)
