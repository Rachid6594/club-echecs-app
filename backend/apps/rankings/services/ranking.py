from dataclasses import dataclass
from enum import StrEnum
from collections.abc import Iterable


class MatchOutcome(StrEnum):
    WIN = "win"
    DRAW = "draw"
    LOSS = "loss"
    RESIGNATION_WIN = "resignation_win"
    RESIGNATION_LOSS = "resignation_loss"
    TIMEOUT_WIN = "timeout_win"
    TIMEOUT_LOSS = "timeout_loss"


class CompetitionBonus(StrEnum):
    CHAMPION = "champion"
    FINALIST = "finalist"
    SEMI_FINALIST = "semi_finalist"
    PARTICIPATION = "participation"


BONUS_POINTS = {
    CompetitionBonus.CHAMPION: 50,
    CompetitionBonus.FINALIST: 30,
    CompetitionBonus.SEMI_FINALIST: 15,
    CompetitionBonus.PARTICIPATION: 5,
}

RANK_THRESHOLDS = [
    ("Legende", 3000),
    ("Grand Maitre du Club", 2200),
    ("Maitre du Club", 1700),
    ("Stratege III", 1350),
    ("Stratege II", 1050),
    ("Stratege I", 800),
    ("Intermediaire III", 600),
    ("Intermediaire II", 450),
    ("Intermediaire I", 320),
    ("Apprenti III", 230),
    ("Apprenti II", 160),
    ("Apprenti I", 100),
    ("Novice III", 60),
    ("Novice II", 30),
    ("Novice I", 0),
]


@dataclass(frozen=True)
class PlayerStanding:
    user_id: str
    points: int = 0
    wins: int = 0
    draws: int = 0
    losses: int = 0
    bonus_points: int = 0

    @property
    def games_played(self) -> int:
        return self.wins + self.draws + self.losses

    @property
    def total_points(self) -> int:
        return self.points + self.bonus_points

    @property
    def rank_name(self) -> str:
        return rank_for_points(self.total_points)


def points_for_outcome(outcome: MatchOutcome) -> tuple[int, int, int, int]:
    if outcome in {
        MatchOutcome.WIN,
        MatchOutcome.RESIGNATION_WIN,
        MatchOutcome.TIMEOUT_WIN,
    }:
        return 3, 1, 0, 0
    if outcome == MatchOutcome.DRAW:
        return 1, 0, 1, 0
    if outcome in {
        MatchOutcome.LOSS,
        MatchOutcome.RESIGNATION_LOSS,
        MatchOutcome.TIMEOUT_LOSS,
    }:
        return 0, 0, 0, 1
    raise ValueError(f"Outcome non supporte: {outcome}")


def apply_match_result(standing: PlayerStanding, outcome: MatchOutcome) -> PlayerStanding:
    points, wins, draws, losses = points_for_outcome(outcome)
    return PlayerStanding(
        user_id=standing.user_id,
        points=standing.points + points,
        wins=standing.wins + wins,
        draws=standing.draws + draws,
        losses=standing.losses + losses,
        bonus_points=standing.bonus_points,
    )


def apply_competition_bonus(standing: PlayerStanding, bonus: CompetitionBonus) -> PlayerStanding:
    return PlayerStanding(
        user_id=standing.user_id,
        points=standing.points,
        wins=standing.wins,
        draws=standing.draws,
        losses=standing.losses,
        bonus_points=standing.bonus_points + BONUS_POINTS[bonus],
    )


def rank_for_points(points: int) -> str:
    if points < 0:
        raise ValueError("Les points ne peuvent pas etre negatifs.")
    for name, threshold in RANK_THRESHOLDS:
        if points >= threshold:
            return name
    return "Novice I"


def recompute_standings(events: dict[str, list[MatchOutcome]]) -> list[PlayerStanding]:
    standings: dict[str, PlayerStanding] = {}
    for user_id, outcomes in events.items():
        standing = standings.get(user_id, PlayerStanding(user_id=user_id))
        for outcome in outcomes:
            standing = apply_match_result(standing, outcome)
        standings[user_id] = standing
    return sort_standings(standings.values())


def sort_standings(standings: Iterable[PlayerStanding]) -> list[PlayerStanding]:
    return sorted(
        list(standings),
        key=lambda standing: (
            -standing.total_points,
            -standing.wins,
            standing.losses,
            standing.user_id,
        ),
    )


def top_10_general(standings: list[PlayerStanding]) -> list[PlayerStanding]:
    return sort_standings(standings)[:10]


def player_stats(standing: PlayerStanding) -> dict:
    return {
        "user_id": standing.user_id,
        "points": standing.total_points,
        "match_points": standing.points,
        "bonus_points": standing.bonus_points,
        "wins": standing.wins,
        "draws": standing.draws,
        "losses": standing.losses,
        "games_played": standing.games_played,
        "rank_name": standing.rank_name,
    }
