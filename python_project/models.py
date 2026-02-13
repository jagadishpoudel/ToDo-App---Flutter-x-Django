from django.db import models
from django.contrib.auth.models import User

# Create your models here.

class Skill(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='skills', null=True, blank=True)
    name = models.CharField(max_length=100)
    skill = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        username = self.user.username if self.user else "Unknown"
        return f"{self.name} - {username}"
    
    class Meta:
        ordering = ['-created_at']
