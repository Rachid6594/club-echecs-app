from dataclasses import dataclass
from enum import StrEnum


class PlayerColor(StrEnum):
    WHITE = "white"
    BLACK = "black"


class GameEndReason(StrEnum):
    CHECKMATE = "checkmate"
    STALEMATE = "stalemate"
    DRAW_AGREEMENT = "draw_agreement"
    RESIGNATION = "resignation"
    TIMEOUT = "timeout"


class GameOutcome(StrEnum):
    WHITE_WIN = "white_win"
    BLACK_WIN = "black_win"
    DRAW = "draw"


class ClockError(ValueError):
    pass


class DrawOfferError(ValueError):
    pass


@dataclass(frozen=True)
class TimeControl:
    name: str
    initial_seconds: int
    increment_seconds: int = 0

    def __post_init__(self):
        if self.initial_seconds <= 0:
            raise ClockError("Le temps initial doit etre positif.")
        if self.increment_seconds < 0:
            raise ClockError("L'increment doit etre positif ou nul.")


TIME_CONTROLS = {
    "bullet_1_0": TimeControl("Bullet 1+0", 60, 0),
    "blitz_3_2": TimeControl("Blitz 3+2", 180, 2),
    "blitz_5_0": TimeControl("Blitz 5+0", 300, 0),
    "rapid_10_5": TimeControl("Rapide 10+5", 600, 5),
    "rapid_15_10": TimeControl("Rapide 15+10", 900, 10),
}


@dataclass(frozen=True)
class GameResult:
    outcome: GameOutcome
    reason: GameEndReason
    winner: PlayerColor | None
    white_points: int
    black_points: int


@dataclass
class GameClock:
    initial_ms: int
    increment_ms: int
    white_remaining_ms: int
    black_remaining_ms: int
    active_color: PlayerColor = PlayerColor.WHITE
    is_flagged: bool = False

    @classmethod
    def from_time_control(cls, time_control: TimeControl) -> "GameClock":
        initial_ms = time_control.initial_seconds * 1000
        return cls(
            initial_ms=initial_ms,
            increment_ms=time_control.increment_seconds * 1000,
            white_remaining_ms=initial_ms,
            black_remaining_ms=initial_ms,
        )

    def tick(self, elapsed_ms: int) -> None:
        if elapsed_ms < 0:
            raise ClockError("Le temps ecoule ne peut pas etre negatif.")
        if self.is_flagged:
            return

        if self.active_color == PlayerColor.WHITE:
            self.white_remaining_ms = max(0, self.white_remaining_ms - elapsed_ms)
            self.is_flagged = self.white_remaining_ms == 0
        else:
            self.black_remaining_ms = max(0, self.black_remaining_ms - elapsed_ms)
            self.is_flagged = self.black_remaining_ms == 0

    def complete_move(self, elapsed_ms: int) -> GameResult | None:
        moving_color = self.active_color
        self.tick(elapsed_ms)
        if self.is_flagged:
            return timeout_result(moving_color)

        if moving_color == PlayerColor.WHITE:
            self.white_remaining_ms += self.increment_ms
            self.active_color = PlayerColor.BLACK
        else:
            self.black_remaining_ms += self.increment_ms
            self.active_color = PlayerColor.WHITE
        return None


@dataclass
class DrawOfferState:
    offered_by: PlayerColor | None = None

    def offer(self, player: PlayerColor) -> None:
        if self.offered_by == player:
            raise DrawOfferError("Une proposition de nul est deja en attente pour ce joueur.")
        if self.offered_by is not None:
            raise DrawOfferError("Une proposition de nul est deja en attente.")
        self.offered_by = player

    def accept(self, player: PlayerColor) -> GameResult:
        if self.offered_by is None:
            raise DrawOfferError("Aucune proposition de nul en attente.")
        if self.offered_by == player:
            raise DrawOfferError("Le joueur qui propose ne peut pas accepter sa propre proposition.")
        self.offered_by = None
        return draw_result(GameEndReason.DRAW_AGREEMENT)

    def reject(self, player: PlayerColor) -> None:
        if self.offered_by is None:
            raise DrawOfferError("Aucune proposition de nul en attente.")
        if self.offered_by == player:
            raise DrawOfferError("Le joueur qui propose ne peut pas refuser sa propre proposition.")
        self.offered_by = None


def result_for_winner(winner: PlayerColor, reason: GameEndReason) -> GameResult:
    if winner == PlayerColor.WHITE:
        return GameResult(GameOutcome.WHITE_WIN, reason, PlayerColor.WHITE, 3, 0)
    return GameResult(GameOutcome.BLACK_WIN, reason, PlayerColor.BLACK, 0, 3)


def draw_result(reason: GameEndReason) -> GameResult:
    return GameResult(GameOutcome.DRAW, reason, None, 1, 1)


def resignation_result(resigning_player: PlayerColor) -> GameResult:
    winner = PlayerColor.BLACK if resigning_player == PlayerColor.WHITE else PlayerColor.WHITE
    return result_for_winner(winner, GameEndReason.RESIGNATION)


def timeout_result(flagged_player: PlayerColor) -> GameResult:
    winner = PlayerColor.BLACK if flagged_player == PlayerColor.WHITE else PlayerColor.WHITE
    return result_for_winner(winner, GameEndReason.TIMEOUT)


def result_from_chess_status(status: dict) -> GameResult | None:
    outcome = status.get("outcome")
    if status.get("is_checkmate"):
        winner = PlayerColor.BLACK if status.get("turn") == PlayerColor.WHITE else PlayerColor.WHITE
        return result_for_winner(winner, GameEndReason.CHECKMATE)
    if status.get("is_stalemate") or outcome == "1/2-1/2":
        return draw_result(GameEndReason.STALEMATE)
    return None

