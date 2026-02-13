#!/usr/bin/env python3
"""
Script to populate initial skills data into the database.
Run this once after migrations: python3 manage.py shell < populate_skills.py
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'django_first_project.settings')
django.setup()

from python_project.models import Skill

# Clear existing skills (optional)
# Skill.objects.all().delete()

# Add initial skills from the database.py
initial_skills = [
    {
        'name': 'Flutter Developer',
        'skill': 'Dart, Flutter, Provider, Riverpod, Bloc.'
    },
    {
        'name': 'Django Developer',
        'skill': 'Html, Python, Django.'
    }
]

for skill_data in initial_skills:
    skill, created = Skill.objects.get_or_create(
        name=skill_data['name'],
        defaults={'skill': skill_data['skill']}
    )
    if created:
        print(f"Created skill: {skill.name}")
    else:
        print(f"Skill already exists: {skill.name}")

print("Done!")
