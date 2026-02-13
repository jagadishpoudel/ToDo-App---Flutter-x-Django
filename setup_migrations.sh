#!/bin/bash
# Setup script for Django migrations

cd /Users/jagadishpoudel/Development/django_/full_project

echo "Creating migrations..."
python3 manage.py makemigrations python_project

echo "Applying migrations..."
python3 manage.py migrate

echo "Done! Database is ready."
