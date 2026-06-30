from datetime import timedelta
import uuid

from django.conf import settings
from django.db import models
from django.utils import timezone


def default_invitation_expiry():
    return timezone.now() + timedelta(days=7)


class ClubMember(models.Model):
    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        ACTIVE = "active", "Active"
        SUSPENDED = "suspended", "Suspended"
        LEFT = "left", "Left"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="club_member")
    member_number = models.CharField(max_length=40, unique=True, blank=True, null=True)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    joined_at = models.DateTimeField(null=True, blank=True)
    suspended_at = models.DateTimeField(null=True, blank=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self) -> str:
        return f"{self.user.username} ({self.status})"


class Invitation(models.Model):
    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        ACCEPTED = "accepted", "Accepted"
        REJECTED = "rejected", "Rejected"
        CANCELLED = "cancelled", "Cancelled"
        EXPIRED = "expired", "Expired"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="sent_invitations")
    receiver = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="received_invitations")
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    proposed_initial_seconds = models.PositiveIntegerField(default=600)
    proposed_increment_seconds = models.PositiveIntegerField(default=0)
    message = models.TextField(blank=True)
    expires_at = models.DateTimeField(default=default_invitation_expiry)
    responded_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        constraints = [
            models.CheckConstraint(
                condition=~models.Q(sender=models.F("receiver")),
                name="clubs_invitation_distinct_users",
            ),
            models.UniqueConstraint(
                fields=("sender", "receiver"),
                condition=models.Q(status="pending"),
                name="clubs_one_pending_invitation_pair",
            ),
        ]

    def mark_expired_if_needed(self) -> bool:
        if self.status == self.Status.PENDING and self.expires_at <= timezone.now():
            self.status = self.Status.EXPIRED
            self.responded_at = timezone.now()
            self.save(update_fields=["status", "responded_at", "updated_at"])
            return True
        return False

    def __str__(self) -> str:
        return f"{self.sender} -> {self.receiver} ({self.status})"
