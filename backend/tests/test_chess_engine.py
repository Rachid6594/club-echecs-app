import pytest

from apps.games.services.chess_engine import ChessGameState, IllegalMoveError


def test_legal_move_updates_fen_and_history():
    game = ChessGameState()

    result = game.play_uci("e2e4")

    assert result.san == "e4"
    assert result.side == "white"
    assert result.move_number == 1
    assert result.fen_before != result.fen_after
    assert game.history == [result]


def test_illegal_move_is_rejected():
    game = ChessGameState()

    with pytest.raises(IllegalMoveError):
        game.play_uci("e2e5")


def test_check_and_checkmate_detection_with_fools_mate():
    game = ChessGameState()
    for move in ["f2f3", "e7e5", "g2g4"]:
        game.play_uci(move)

    result = game.play_uci("d8h4")

    assert result.is_check
    assert result.is_checkmate
    assert result.outcome == "0-1"


def test_stalemate_detection():
    game = ChessGameState.from_fen("7k/5Q2/6K1/8/8/8/8/8 b - - 0 1")

    status = game.status()

    assert status["is_stalemate"]
    assert status["outcome"] == "1/2-1/2"


def test_castling_detection():
    game = ChessGameState()
    for move in ["e2e4", "e7e5", "g1f3", "b8c6", "f1c4", "g8f6"]:
        game.play_uci(move)

    result = game.play_uci("e1g1")

    assert result.is_castling
    assert result.san == "O-O"


def test_promotion_detection():
    game = ChessGameState.from_fen("8/6Pk/8/8/8/8/6K1/8 w - - 0 1")

    result = game.play_uci("g7g8q")

    assert result.promotion_piece == "q"
    assert result.san == "g8=Q+"


def test_en_passant_detection():
    game = ChessGameState()
    for move in ["e2e4", "a7a6", "e4e5", "d7d5"]:
        game.play_uci(move)

    result = game.play_uci("e5d6")

    assert result.is_en_passant
    assert result.is_capture


def test_pgn_history_is_generated():
    game = ChessGameState()
    for move in ["e2e4", "e7e5", "g1f3"]:
        game.play_uci(move)

    pgn = game.pgn()

    assert "1. e4 e5 2. Nf3" in pgn
