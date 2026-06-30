from django.contrib.auth import get_user_model
from django.urls import reverse
import pytest

from apps.accounts.models import UserProfile


User = get_user_model()
pytestmark = pytest.mark.django_db


def test_register_creates_player_profile_and_tokens(client):
    response = client.post(
        reverse("auth-register"),
        {
            "username": "playerone",
            "email": "PlayerOne@example.com",
            "password": "StrongPass123",
            "display_name": "Player One",
        },
        content_type="application/json",
    )

    assert response.status_code == 201
    payload = response.json()
    assert payload["user"]["email"] == "playerone@example.com"
    assert payload["user"]["role"] == "player"
    assert payload["user"]["profile"]["display_name"] == "Player One"
    assert payload["tokens"]["access"]
    assert payload["tokens"]["refresh"]
    assert User.objects.filter(email="playerone@example.com").exists()
    assert UserProfile.objects.filter(display_name="Player One").exists()


def test_register_rejects_duplicate_email_case_insensitive(client):
    User.objects.create_user(username="first", email="same@example.com", password="StrongPass123")

    response = client.post(
        reverse("auth-register"),
        {
            "username": "second",
            "email": "SAME@example.com",
            "password": "StrongPass123",
        },
        content_type="application/json",
    )

    assert response.status_code == 400
    assert "email" in response.json()


def test_login_returns_tokens(client):
    User.objects.create_user(username="player", email="player@example.com", password="StrongPass123")

    response = client.post(
        reverse("auth-login"),
        {"email": "player@example.com", "password": "StrongPass123"},
        content_type="application/json",
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["user"]["username"] == "player"
    assert payload["tokens"]["access"]
    assert payload["tokens"]["refresh"]


def test_me_requires_authentication(client):
    response = client.get(reverse("auth-me"))

    assert response.status_code == 401


def test_me_returns_current_user(api_client):
    user = User.objects.create_user(username="me", email="me@example.com", password="StrongPass123")
    UserProfile.objects.create(user=user, display_name="Me")
    api_client.force_authenticate(user=user)

    response = api_client.get(reverse("auth-me"))

    assert response.status_code == 200
    assert response.json()["email"] == "me@example.com"


def test_update_profile(api_client):
    user = User.objects.create_user(username="profile", email="profile@example.com", password="StrongPass123")
    UserProfile.objects.create(user=user, display_name="Old Name")
    api_client.force_authenticate(user=user)

    response = api_client.patch(
        reverse("auth-me"),
        {
            "profile": {
                "display_name": "New Name",
                "bio": "Blitz player",
                "country_code": "BF",
            }
        },
        format="json",
    )

    assert response.status_code == 200
    user.profile.refresh_from_db()
    assert user.profile.display_name == "New Name"
    assert user.profile.bio == "Blitz player"
    assert user.profile.country_code == "BF"


def test_refresh_and_logout_flow(client):
    register_response = client.post(
        reverse("auth-register"),
        {
            "username": "tokenuser",
            "email": "token@example.com",
            "password": "StrongPass123",
        },
        content_type="application/json",
    )
    tokens = register_response.json()["tokens"]

    refresh_response = client.post(
        reverse("token-refresh"),
        {"refresh": tokens["refresh"]},
        content_type="application/json",
    )
    assert refresh_response.status_code == 200
    assert refresh_response.json()["access"]
    rotated_refresh = refresh_response.json()["refresh"]

    logout_response = client.post(
        reverse("auth-logout"),
        {"refresh": rotated_refresh},
        HTTP_AUTHORIZATION=f"Bearer {tokens['access']}",
        content_type="application/json",
    )
    assert logout_response.status_code == 204
