from datetime import timedelta

from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework import serializers

from apps.accounts.serializers import UserProfileSerializer
from apps.clubs.models import ClubMember, Invitation


User = get_user_model()


class MemberUserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(read_only=True)

    class Meta:
        model = User
        fields = ("id", "username", "email", "role", "profile")


class ClubMemberSerializer(serializers.ModelSerializer):
    user = MemberUserSerializer(read_only=True)

    class Meta:
        model = ClubMember
        fields = ("id", "user", "member_number", "status", "joined_at")


class MemberStatsSerializer(serializers.Serializer):
    user_id = serializers.UUIDField()
    games_played = serializers.IntegerField()
    wins = serializers.IntegerField()
    draws = serializers.IntegerField()
    losses = serializers.IntegerField()
    points = serializers.IntegerField()


class InvitationSerializer(serializers.ModelSerializer):
    sender = MemberUserSerializer(read_only=True)
    receiver = MemberUserSerializer(read_only=True)
    receiver_id = serializers.UUIDField(write_only=True)

    class Meta:
        model = Invitation
        fields = (
            "id",
            "sender",
            "receiver",
            "receiver_id",
            "status",
            "proposed_initial_seconds",
            "proposed_increment_seconds",
            "message",
            "expires_at",
            "responded_at",
            "created_at",
        )
        read_only_fields = ("id", "status", "expires_at", "responded_at", "created_at")

    def validate_receiver_id(self, value):
        request = self.context["request"]
        if value == request.user.id:
            raise serializers.ValidationError("Impossible de s'inviter soi-meme.")
        if not ClubMember.objects.filter(user_id=value, status=ClubMember.Status.ACTIVE).exists():
            raise serializers.ValidationError("Le destinataire n'est pas un membre actif.")
        return value

    def validate(self, attrs):
        initial = attrs.get("proposed_initial_seconds", 600)
        increment = attrs.get("proposed_increment_seconds", 0)
        if initial <= 0:
            raise serializers.ValidationError({"proposed_initial_seconds": "La duree initiale doit etre positive."})
        if increment < 0:
            raise serializers.ValidationError({"proposed_increment_seconds": "L'increment doit etre positif ou nul."})
        return attrs

    def create(self, validated_data):
        receiver_id = validated_data.pop("receiver_id")
        if Invitation.objects.filter(
            sender=self.context["request"].user,
            receiver_id=receiver_id,
            status=Invitation.Status.PENDING,
        ).exists():
            raise serializers.ValidationError("Une invitation en attente existe deja pour ce membre.")

        return Invitation.objects.create(
            sender=self.context["request"].user,
            receiver_id=receiver_id,
            expires_at=timezone.now() + timedelta(days=7),
            **validated_data,
        )
