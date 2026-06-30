import pytest

from apps.games.services.chess_engine import ChessGameState
from apps.games.services.game_lifecycle import (
    ClockError,
    DrawOfferError,
    DrawOfferState,
    GameClock,
    GameEndReason,
    GameOutcome,
    PlayerColor,
    TIME_CONTROLS,
    TimeControl,
    resignation_result,
    result_from_chess_status,
    timeout_result,
)


def test_required_time_controls_are_available():
    assert TIME_CONTROLS["bullet_1_0"].initial_seconds == 60
    assert TIME_CONTROLS["blitz_3_2"].increment_seconds == 2
    assert TIME_CONTROLS["blitz_5_0"].initial_seconds == 300
    assert TIME_CONTROLS["rapid_10_5"].increment_seconds == 5
    assert TIME_CONTROLS["rapid_15_10"].initial_seconds == 900


def test_custom_time_control_validation():
    custom = TimeControl("Personnalise 20+3", 1200, 3)

    assert custom.initial_seconds == 1200
    assert custom.increment_seconds == 3

    with pytest.raises(ClockError):
        TimeControl("Invalid", 0, 0)


def test_clock_applies_increment_and_switches_turn():
    clock = GameClock.from_time_control(TIME_CONTROLS["blitz_3_2"])

    result = clock.complete_move(10_000)

    assert result is None
    assert clock.white_remaining_ms == 172_000
    assert clock.black_remaining_ms == 180_000
    assert clock.active_color == PlayerColor.BLACK


def test_timeout_ends_game_with_points():
    clock = GameClock.from_time_control(TIME_CONTROLS["bullet_1_0"])

    result = clock.complete_move(61_000)

    assert result.outcome == GameOutcome.BLACK_WIN
    assert result.reason == GameEndReason.TIMEOUT
    assert result.white_points == 0
    assert result.black_points == 3


def test_resignation_result_awards_opponent():
    result = resignation_result(PlayerColor.BLACK)

    assert result.outcome == GameOutcome.WHITE_WIN
    assert result.winner == PlayerColor.WHITE
    assert result.white_points == 3
    assert result.black_points == 0


def test_draw_offer_accept_and_reject_flow():
    draw = DrawOfferState()
    draw.offer(PlayerColor.WHITE)

    with pytest.raises(DrawOfferError):
        draw.accept(PlayerColor.WHITE)

    result = draw.accept(PlayerColor.BLACK)
    assert result.outcome == GameOutcome.DRAW
    assert result.white_points == 1
    assert result.black_points == 1

    draw.offer(PlayerColor.BLACK)
    draw.reject(PlayerColor.WHITE)
    assert draw.offered_by is None


def test_timeout_result_helper():
    result = timeout_result(PlayerColor.WHITE)

    assert result.outcome == GameOutcome.BLACK_WIN
    assert result.reason == GameEndReason.TIMEOUT


def test_checkmate_status_maps_to_result():
    game = ChessGameState()
    for move in ["f2f3", "e7e5", "g2g4", "d8h4"]:
        game.play_uci(move)

    result = result_from_chess_status(game.status())

    assert result.outcome == GameOutcome.BLACK_WIN
    assert result.reason == GameEndReason.CHECKMATE


def test_stalemate_status_maps_to_draw():
    game = ChessGameState.from_fen("7k/5Q2/6K1/8/8/8/8/8 b - - 0 1")

    result = result_from_chess_status(game.status())

    assert result.outcome == GameOutcome.DRAW
    assert result.reason == GameEndReason.STALEMATE

