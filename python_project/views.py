from django.shortcuts import render
from rest_framework.response import Response
from rest_framework.decorators import api_view
from . import database
from rest_framework import status
from .models import Skill
from .serializers import SkillSerializer

# Create your views here.
# Request Handler

def myapp(request):
    return render(request, "main.html", {'name': 'Jagadish Poudel'})

@api_view(['GET', 'POST'])
def getData(request):
    try:
        if request.method == 'GET':
            # Fetch all skills from the database
            skills = Skill.objects.all()
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
                
                # Save to database
                new_skill = Skill.objects.create(name=name, skill=skill)
                
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
                    skill = Skill.objects.get(id=skill_id)
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
def updateSkill(request, skill_id):
    """Update a skill by ID"""
    try:
        skill = Skill.objects.get(id=skill_id)
    except Skill.DoesNotExist:
        return Response(
            {'error': 'Skill not found'},
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
def deleteSkill(request, skill_id):
    """Delete a skill by ID"""
    try:
        skill = Skill.objects.get(id=skill_id)
    except Skill.DoesNotExist:
        return Response(
            {'error': 'Skill not found'},
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
