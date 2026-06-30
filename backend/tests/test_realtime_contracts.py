import pytest

from apps.games.services.realtime import (
    RealtimeConfig,
    RealtimeEvent,
    RealtimePublisher,
    clock_payload,
    game_channel,
    game_status_payload,
    invitation_channel,
    move_payload,
    notification_channel,
    spectator_channel,
    spectator_presence_payload,
    tournament_channel,
    view_count_payload,
)


def test_channel_names_are_stable():
    assert game_channel("g1") == "game:g1"
    assert spectator_channel("g1") == "game:g1:spectators"
    assert invitation_channel("u1") == "user:u1:invitations"
    assert notification_channel("u1") == "user:u1:notifications"
    assert tournament_channel("t1") == "tournament:t1:bracket"


def test_move_payload_contract():
    payload = move_payload(
        game_id="g1",
        move_id="m1",
        player_id="u1",
        uci="e2e4",
        san="e4",
        fen_after="fen",
        move_number=1,
        side="white",
    )

    assert payload["event"] == RealtimeEvent.MOVE_PLAYED
    assert payload["uci"] == "e2e4"
    assert payload["fen_after"] == "fen"


def test_status_clock_and_view_payloads():
    status = game_status_payload(game_id="g1", status="active")
    clock = clock_payload(
        game_id="g1",
        active_side="black",
        white_remaining_ms=10_000,
        black_remaining_ms=12_000,
    )
    views = view_count_payload(game_id="g1", total_views=42)

    assert status["event"] == RealtimeEvent.GAME_STATUS
    assert clock["event"] == RealtimeEvent.CLOCK_UPDATED
    assert views["total_views"] == 42


def test_spectator_presence_payload_validates_event():
    payload = spectator_presence_payload(
        game_id="g1",
        spectator_id="s1",
        live_count=3,
        event=RealtimeEvent.SPECTATOR_JOINED,
    )

    assert payload["live_count"] == 3

    with pytest.raises(ValueError):
        spectator_presence_payload(
            game_id="g1",
            spectator_id="s1",
            live_count=3,
            event=RealtimeEvent.MOVE_PLAYED,
        )


def test_publisher_wraps_reconnect_policy():
    publisher = RealtimePublisher(
        RealtimeConfig(
            supabase_url="https://example.supabase.co",
            service_role_key="test-service-role",
            reconnect_attempts=7,
            reconnect_backoff_ms=250,
        )
    )
    payload = game_status_payload(game_id="g1", status="completed", result="draw")

    broadcast = publisher.broadcast_game_status(payload)

    assert broadcast["channel"] == "game:g1"
    assert broadcast["event"] == RealtimeEvent.GAME_STATUS
    assert broadcast["reconnect"] == {"attempts": 7, "backoff_ms": 250}


def test_realtime_config_reports_missing_env(monkeypatch):
    monkeypatch.delenv("SUPABASE_URL", raising=False)
    monkeypatch.delenv("SUPABASE_SERVICE_ROLE_KEY", raising=False)

    config = RealtimeConfig.from_env()

    assert not config.is_configured

