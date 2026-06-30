from django.contrib import admin

from apps.clubs.models import ClubMember, Invitation


@admin.register(ClubMember)
class ClubMemberAdmin(admin.ModelAdmin):
    list_display = ("user", "member_number", "status", "joined_at")
    list_filter = ("status",)
    search_fields = ("user__username", "user__email", "member_number")


@admin.register(Invitation)
class InvitationAdmin(admin.ModelAdmin):
    list_display = ("sender", "receiver", "status", "expires_at", "created_at")
    list_filter = ("status",)
    search_fields = ("sender__username", "receiver__username", "sender__email", "receiver__email")

