from django.urls import path
from . import views

urlpatterns = [
    path('', views.myapp),
    # Authentication
    path('auth/register/', views.register),
    path('auth/login/', views.login),
    # Skills
    path('skills/api/', views.getData),
    path('skills/api/<int:skill_id>/', views.updateSkill),
    path('skills/api/<int:skill_id>/delete/', views.deleteSkill),
    # Admin
    path('admin/', views.admin_dashboard),
    path('admin/delete-user/<int:user_id>/', views.delete_user_admin),
    path('admin/delete-skill/<int:skill_id>/', views.delete_skill_admin),
]
