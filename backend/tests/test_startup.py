from django.conf import settings
from django.urls import reverse


def test_django_settings_are_loaded():
    assert settings.ROOT_URLCONF == "config.urls"
    assert settings.AUTH_USER_MODEL == "accounts.User"
    assert "rest_framework" in settings.INSTALLED_APPS
    assert "corsheaders" in settings.INSTALLED_APPS


def test_health_endpoint_is_public(client):
    response = client.get(reverse("health-check"))

    assert response.status_code == 200
    assert response.json() == {"status": "ok", "service": "club-echecs-api"}

