from apps.notifications.services.notifications import (
    NotificationType,
    badge_earned_notification,
    competition_start_notification,
    invitation_notification,
    mark_as_read,
    match_generated_notification,
    match_reminder_notification,
    result_notification,
)


def test_invitation_notification_payload():
    notification = invitation_notification("u1", "inv1", "Awa")

    assert notification.type == NotificationType.INVITATION
    assert notification.title == "Invitation recue"
    assert notification.payload == {"invitation_id": "inv1"}


def test_match_reminder_notification():
    notification = match_reminder_notification("u1", "m1", "2026-07-01T10:00:00Z")

    assert notification.type == NotificationType.MATCH_REMINDER
    assert notification.payload["starts_at"] == "2026-07-01T10:00:00Z"


def test_competition_and_generated_match_notifications():
    competition = competition_start_notification("u1", "t1", "Coupe du Club")
    generated = match_generated_notification("u1", "m1", "Moussa")

    assert competition.type == NotificationType.COMPETITION_START
    assert "Coupe du Club" in competition.body
    assert generated.type == NotificationType.MATCH_GENERATED
    assert generated.payload["match_id"] == "m1"


def test_result_and_badge_notifications():
    result = result_notification("u1", "g1", "white_win")
    badge = badge_earned_notification("u1", "first_win", "Premiere victoire")

    assert result.type == NotificationType.RESULT
    assert result.payload["result"] == "white_win"
    assert badge.type == NotificationType.BADGE_EARNED
    assert badge.payload["badge_code"] == "first_win"


def test_mark_as_read_returns_updated_notification():
    notification = invitation_notification("u1", "inv1", "Awa")

    read = mark_as_read(notification)

    assert read.id == notification.id
    assert read.read is True
    assert notification.read is False

