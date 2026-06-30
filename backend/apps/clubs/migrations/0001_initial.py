import uuid

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import apps.clubs.models


class Migration(migrations.Migration):
    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name="ClubMember",
            fields=[
                ("id", models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ("member_number", models.CharField(blank=True, max_length=40, null=True, unique=True)),
                ("status", models.CharField(choices=[("pending", "Pending"), ("active", "Active"), ("suspended", "Suspended"), ("left", "Left")], default="pending", max_length=20)),
                ("joined_at", models.DateTimeField(blank=True, null=True)),
                ("suspended_at", models.DateTimeField(blank=True, null=True)),
                ("notes", models.TextField(blank=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                ("user", models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name="club_member", to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name="Invitation",
            fields=[
                ("id", models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ("status", models.CharField(choices=[("pending", "Pending"), ("accepted", "Accepted"), ("rejected", "Rejected"), ("cancelled", "Cancelled"), ("expired", "Expired")], default="pending", max_length=20)),
                ("proposed_initial_seconds", models.PositiveIntegerField(default=600)),
                ("proposed_increment_seconds", models.PositiveIntegerField(default=0)),
                ("message", models.TextField(blank=True)),
                ("expires_at", models.DateTimeField(default=apps.clubs.models.default_invitation_expiry)),
                ("responded_at", models.DateTimeField(blank=True, null=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                ("receiver", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="received_invitations", to=settings.AUTH_USER_MODEL)),
                ("sender", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="sent_invitations", to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.AddConstraint(
            model_name="invitation",
            constraint=models.CheckConstraint(condition=models.Q(("sender", models.F("receiver")), _negated=True), name="clubs_invitation_distinct_users"),
        ),
        migrations.AddConstraint(
            model_name="invitation",
            constraint=models.UniqueConstraint(condition=models.Q(("status", "pending")), fields=("sender", "receiver"), name="clubs_one_pending_invitation_pair"),
        ),
    ]
