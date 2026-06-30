from datetime import timedelta

from django.contrib.auth import get_user_model
from django.urls import reverse
from django.utils import timezone
import pytest

from apps.accounts.models import UserProfile
from apps.clubs.models import ClubMember, Invitation


User = get_user_model()
pytestmark = pytest.mark.django_db


def create_member(username, email, status=ClubMember.Status.ACTIVE):
    user = User.objects.create_user(username=username, email=email, password="StrongPass123")
    UserProfile.objects.create(user=user, display_name=username.title())
    member = ClubMember.objects.create(
        user=user,
        status=status,
        joined_at=timezone.now() if status == ClubMember.Status.ACTIVE else None,
    )
    return user, member


def test_member_list_requires_authentication(client):
    response = client.get(reverse("member-list"))

    assert response.status_code == 401


def test_member_list_returns_active_members_and_supports_search(api_client):
    user, _ = create_member("alice", "alice@example.com")
    create_member("bob", "bob@example.com")
    create_member("charlie", "charlie@example.com", status=ClubMember.Status.SUSPENDED)
    api_client.force_authenticate(user=user)

    response = api_client.get(reverse("member-list"), {"search": "bo"})

    assert response.status_code == 200
    payload = response.json()
    assert len(payload) == 1
    assert payload[0]["user"]["username"] == "bob"


def test_member_detail_and_stats(api_client):
    viewer, _ = create_member("viewer", "viewer@example.com")
    _, target_member = create_member("target", "target@example.com")
    api_client.force_authenticate(user=viewer)

    detail_response = api_client.get(reverse("member-detail", args=[target_member.id]))
    stats_response = api_client.get(reverse("member-stats", args=[target_member.id]))

    assert detail_response.status_code == 200
    assert detail_response.json()["user"]["username"] == "target"
    assert stats_response.status_code == 200
    assert stats_response.json()["points"] == 0


def test_create_invitation_to_member(api_client):
    sender, _ = create_member("sender", "sender@example.com")
    receiver, receiver_member = create_member("receiver", "receiver@example.com")
    api_client.force_authenticate(user=sender)

    response = api_client.post(
        reverse("member-invite", args=[receiver_member.id]),
        {"proposed_initial_seconds": 300, "proposed_increment_seconds": 2, "message": "Blitz ?"},
        format="json",
    )

    assert response.status_code == 201
    invitation = Invitation.objects.get()
    assert invitation.sender == sender
    assert invitation.receiver == receiver
    assert invitation.status == Invitation.Status.PENDING


def test_invitation_rejects_self_and_duplicate(api_client):
    sender, sender_member = create_member("sender", "sender@example.com")
    receiver, receiver_member = create_member("receiver", "receiver@example.com")
    api_client.force_authenticate(user=sender)

    self_response = api_client.post(reverse("member-invite", args=[sender_member.id]), {}, format="json")
    assert self_response.status_code == 400

    first_response = api_client.post(reverse("member-invite", args=[receiver_member.id]), {}, format="json")
    duplicate_response = api_client.post(reverse("member-invite", args=[receiver_member.id]), {}, format="json")

    assert first_response.status_code == 201
    assert duplicate_response.status_code == 400
    assert Invitation.objects.filter(sender=sender, receiver=receiver).count() == 1


def test_received_and_sent_invitation_lists(api_client):
    sender, _ = create_member("sender", "sender@example.com")
    receiver, _ = create_member("receiver", "receiver@example.com")
    Invitation.objects.create(sender=sender, receiver=receiver)

    api_client.force_authenticate(user=receiver)
    received_response = api_client.get(reverse("invitation-received-list"))
    assert received_response.status_code == 200
    assert received_response.json()[0]["sender"]["username"] == "sender"

    api_client.force_authenticate(user=sender)
    sent_response = api_client.get(reverse("invitation-sent-list"))
    assert sent_response.status_code == 200
    assert sent_response.json()[0]["receiver"]["username"] == "receiver"


def test_accept_reject_cancel_permissions(api_client):
    sender, _ = create_member("sender", "sender@example.com")
    receiver, _ = create_member("receiver", "receiver@example.com")
    outsider, _ = create_member("outsider", "outsider@example.com")
    invitation = Invitation.objects.create(sender=sender, receiver=receiver)

    api_client.force_authenticate(user=outsider)
    forbidden_response = api_client.post(reverse("invitation-action", args=[invitation.id, "accept"]))
    assert forbidden_response.status_code == 403

    api_client.force_authenticate(user=receiver)
    accept_response = api_client.post(reverse("invitation-action", args=[invitation.id, "accept"]))
    assert accept_response.status_code == 200
    invitation.refresh_from_db()
    assert invitation.status == Invitation.Status.ACCEPTED

    second_invitation = Invitation.objects.create(sender=sender, receiver=receiver)
    api_client.force_authenticate(user=sender)
    cancel_response = api_client.post(reverse("invitation-action", args=[second_invitation.id, "cancel"]))
    assert cancel_response.status_code == 200
    second_invitation.refresh_from_db()
    assert second_invitation.status == Invitation.Status.CANCELLED


def test_expired_invitation_cannot_be_accepted(api_client):
    sender, _ = create_member("sender", "sender@example.com")
    receiver, _ = create_member("receiver", "receiver@example.com")
    invitation = Invitation.objects.create(
        sender=sender,
        receiver=receiver,
        expires_at=timezone.now() - timedelta(minutes=1),
    )
    api_client.force_authenticate(user=receiver)

    response = api_client.post(reverse("invitation-action", args=[invitation.id, "accept"]))

    assert response.status_code == 400
    invitation.refresh_from_db()
    assert invitation.status == Invitation.Status.EXPIRED

