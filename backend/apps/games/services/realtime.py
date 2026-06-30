from dataclasses import dataclass
from enum import StrEnum
import os
from typing import Any


class RealtimeEvent(StrEnum):
    MOVE_PLAYED = "move_played"
    GAME_STATUS = "game_status"
    CLOCK_UPDATED = "clock_updated"
    SPECTATOR_JOINED = "spectator_joined"
    SPECTATOR_LEFT = "spectator_left"
    VIEW_COUNT_UPDATED = "view_count_updated"
    INVITATION_UPDATED = "invitation_updated"
    NOTIFICATION_CREATED = "notification_created"
    TOURNAMENT_BRACKET_UPDATED = "tournament_bracket_updated"


@dataclass(frozen=True)
class RealtimeConfig:
    supabase_url: str
    service_role_key: str
    reconnect_attempts: int = 5
    reconnect_backoff_ms: int = 500

    @classmethod
    def from_env(cls) -> "RealtimeConfig":
        url = os.getenv("SUPABASE_URL", "")
        key = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
        return cls(
            supabase_url=url,
            service_role_key=key,
            reconnect_attempts=int(os.getenv("SUPABASE_REALTIME_RECONNECT_ATTEMPTS", "5")),
            reconnect_backoff_ms=int(os.getenv("SUPABASE_REALTIME_RECONNECT_BACKOFF_MS", "500")),
        )

    @property
    def is_configured(self) -> bool:
        return bool(self.supabase_url and self.service_role_key)


def game_channel(game_id: str) -> str:
    return f"game:{game_id}"


def spectator_channel(game_id: str) -> str:
    return f"game:{game_id}:spectators"


def invitation_channel(user_id: str) -> str:
    return f"user:{user_id}:invitations"


def notification_channel(user_id: str) -> str:
    return f"user:{user_id}:notifications"


def tournament_channel(tournament_id: str) -> str:
    return f"tournament:{tournament_id}:bracket"


def move_payload(
    *,
    game_id: str,
    move_id: str,
    player_id: str,
    uci: str,
    san: str,
    fen_after: str,
    move_number: int,
    side: str,
) -> dict[str, Any]:
    return {
        "event": RealtimeEvent.MOVE_PLAYED,
        "game_id": game_id,
        "move_id": move_id,
        "player_id": player_id,
        "uci": uci,
        "san": san,
        "fen_after": fen_after,
        "move_number": move_number,
        "side": side,
    }


def game_status_payload(*, game_id: str, status: str, result: str | None = None) -> dict[str, Any]:
    return {
        "event": RealtimeEvent.GAME_STATUS,
        "game_id": game_id,
        "status": status,
        "result": result,
    }


def clock_payload(
    *,
    game_id: str,
    active_side: str,
    white_remaining_ms: int,
    black_remaining_ms: int,
) -> dict[str, Any]:
    return {
        "event": RealtimeEvent.CLOCK_UPDATED,
        "game_id": game_id,
        "active_side": active_side,
        "white_remaining_ms": white_remaining_ms,
        "black_remaining_ms": black_remaining_ms,
    }


def spectator_presence_payload(
    *,
    game_id: str,
    spectator_id: str,
    live_count: int,
    event: RealtimeEvent,
) -> dict[str, Any]:
    if event not in {RealtimeEvent.SPECTATOR_JOINED, RealtimeEvent.SPECTATOR_LEFT}:
        raise ValueError("Invalid spectator presence event.")
    return {
        "event": event,
        "game_id": game_id,
        "spectator_id": spectator_id,
        "live_count": live_count,
    }


def view_count_payload(*, game_id: str, total_views: int) -> dict[str, Any]:
    return {
        "event": RealtimeEvent.VIEW_COUNT_UPDATED,
        "game_id": game_id,
        "total_views": total_views,
    }


class RealtimePublisher:
    def __init__(self, config: RealtimeConfig | None = None):
        self.config = config or RealtimeConfig.from_env()

    def build_broadcast(self, channel: str, payload: dict[str, Any]) -> dict[str, Any]:
        return {
            "channel": channel,
            "event": payload["event"],
            "payload": payload,
            "reconnect": {
                "attempts": self.config.reconnect_attempts,
                "backoff_ms": self.config.reconnect_backoff_ms,
            },
        }

    def broadcast_move(self, payload: dict[str, Any]) -> dict[str, Any]:
        return self.build_broadcast(game_channel(payload["game_id"]), payload)

    def broadcast_game_status(self, payload: dict[str, Any]) -> dict[str, Any]:
        return self.build_broadcast(game_channel(payload["game_id"]), payload)

    def broadcast_clock(self, payload: dict[str, Any]) -> dict[str, Any]:
        return self.build_broadcast(game_channel(payload["game_id"]), payload)

    def broadcast_spectator_presence(self, payload: dict[str, Any]) -> dict[str, Any]:
        return self.build_broadcast(spectator_channel(payload["game_id"]), payload)

