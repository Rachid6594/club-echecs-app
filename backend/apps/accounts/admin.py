from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from apps.accounts.models import User, UserProfile


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    fieldsets = UserAdmin.fieldsets + (
        ("Club Echecs", {"fields": ("role",)}),
    )
    list_display = ("username", "email", "role", "is_active", "is_staff")
    list_filter = ("role", "is_active", "is_staff", "is_superuser")


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ("display_name", "user", "country_code", "club_joined_at")
    search_fields = ("display_name", "user__username", "user__email")

