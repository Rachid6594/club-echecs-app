from dataclasses import dataclass, field
from enum import StrEnum
from typing import Any
import uuid


class NotificationType(StrEnum):
    INVITATION = "invitation"
    MATCH_REMINDER = "match_reminder"
    COMPETITION_START = "competition_start"
    MATCH_GENERATED = "match_generated"
    RESULT = "result"
    BADGE_EARNED = "badge_earned"


@dataclass(frozen=True)
class Notification:
    id: str
    user_id: str
    type: NotificationType
    title: str
    body: str
    payload: dict[str, Any] = field(default_factory=dict)
    read: bool = False


def _make(user_id: str, type_: NotificationType, title: str, body: str, payload: dict[str, Any]) -> Notification:
    return Notification(str(uuid.uuid4()), user_id, type_, title, body, payload)


def invitation_notification(user_id: str, invitation_id: str, sender_name: str) -> Notification:
    return _make(
        user_id,
        NotificationType.INVITATION,
        "Invitation recue",
        f"{sender_name} vous invite a jouer.",
        {"invitation_id": invitation_id},
    )


def match_reminder_notification(user_id: str, match_id: str, starts_at: str) -> Notification:
    return _make(
        user_id,
        NotificationType.MATCH_REMINDER,
        "Rappel de partie",
        "Votre partie commence bientot.",
        {"match_id": match_id, "starts_at": starts_at},
    )


def competition_start_notification(user_id: str, tournament_id: str, tournament_name: str) -> Notification:
    return _make(
        user_id,
        NotificationType.COMPETITION_START,
        "Competition lancee",
        f"{tournament_name} commence.",
        {"tournament_id": tournament_id},
    )


def match_generated_notification(user_id: str, match_id: str, opponent_name: str) -> Notification:
    return _make(
        user_id,
        NotificationType.MATCH_GENERATED,
        "Match genere",
        f"Votre adversaire est {opponent_name}.",
        {"match_id": match_id},
    )


def result_notification(user_id: str, game_id: str, result: str) -> Notification:
    return _make(
        user_id,
        NotificationType.RESULT,
        "Resultat de partie",
        f"Resultat valide : {result}.",
        {"game_id": game_id, "result": result},
    )


def badge_earned_notification(user_id: str, badge_code: str, badge_name: str) -> Notification:
    return _make(
        user_id,
        NotificationType.BADGE_EARNED,
        "Badge gagne",
        f"Vous avez debloque {badge_name}.",
        {"badge_code": badge_code},
    )


def mark_as_read(notification: Notification) -> Notification:
    return Notification(
        id=notification.id,
        user_id=notification.user_id,
        type=notification.type,
        title=notification.title,
        body=notification.body,
        payload=notification.payload,
        read=True,
    )

