from django.urls import path
from . import views

urlpatterns = [
    path('', views.myapp),
    path('skills/api/', views.getData),
    path('skills/api/<int:skill_id>/', views.updateSkill),
    path('skills/api/<int:skill_id>/delete/', views.deleteSkill),
]
