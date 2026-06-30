from django.contrib.auth import authenticate, get_user_model
from django.db import transaction
from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import UserProfile


User = get_user_model()


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = (
            "display_name",
            "avatar_url",
            "bio",
            "country_code",
            "club_joined_at",
        )


class UserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(read_only=True)

    class Meta:
        model = User
        fields = ("id", "username", "email", "role", "is_active", "profile")
        read_only_fields = ("id", "role", "is_active")


class RegisterSerializer(serializers.Serializer):
    username = serializers.CharField(min_length=3, max_length=150)
    email = serializers.EmailField()
    password = serializers.CharField(min_length=8, write_only=True)
    display_name = serializers.CharField(min_length=2, max_length=120, required=False)

    def validate_username(self, value):
        if User.objects.filter(username__iexact=value).exists():
            raise serializers.ValidationError("Ce nom d'utilisateur est deja utilise.")
        return value

    def validate_email(self, value):
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError("Cet email est deja utilise.")
        return value.lower()

    @transaction.atomic
    def create(self, validated_data):
        display_name = validated_data.pop("display_name", validated_data["username"])
        user = User.objects.create_user(
            username=validated_data["username"],
            email=validated_data["email"],
            password=validated_data["password"],
            role=User.Role.PLAYER,
        )
        UserProfile.objects.create(user=user, display_name=display_name)
        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        email = attrs["email"].lower()
        try:
            user = User.objects.get(email__iexact=email)
        except User.DoesNotExist as exc:
            raise serializers.ValidationError("Identifiants invalides.") from exc

        user = authenticate(
            request=self.context.get("request"),
            username=user.username,
            password=attrs["password"],
        )
        if user is None or not user.is_active:
            raise serializers.ValidationError("Identifiants invalides.")

        attrs["user"] = user
        return attrs


class ProfileUpdateSerializer(serializers.Serializer):
    username = serializers.CharField(min_length=3, max_length=150, required=False)
    email = serializers.EmailField(required=False)
    profile = UserProfileSerializer(required=False)

    def validate_username(self, value):
        user = self.context["request"].user
        if User.objects.exclude(id=user.id).filter(username__iexact=value).exists():
            raise serializers.ValidationError("Ce nom d'utilisateur est deja utilise.")
        return value

    def validate_email(self, value):
        user = self.context["request"].user
        normalized = value.lower()
        if User.objects.exclude(id=user.id).filter(email__iexact=normalized).exists():
            raise serializers.ValidationError("Cet email est deja utilise.")
        return normalized

    @transaction.atomic
    def update(self, instance, validated_data):
        profile_data = validated_data.pop("profile", None)
        for field, value in validated_data.items():
            setattr(instance, field, value)
        instance.save()

        if profile_data:
            profile, _ = UserProfile.objects.get_or_create(
                user=instance,
                defaults={"display_name": instance.username},
            )
            for field, value in profile_data.items():
                setattr(profile, field, value)
            profile.save()

        return instance


def build_token_pair(user):
    refresh = RefreshToken.for_user(user)
    refresh["role"] = user.role
    refresh["email"] = user.email
    return {
        "refresh": str(refresh),
        "access": str(refresh.access_token),
    }

