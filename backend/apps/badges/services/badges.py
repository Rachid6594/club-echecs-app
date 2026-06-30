from dataclasses import dataclass
from enum import StrEnum

from apps.rankings.services.ranking import RANK_THRESHOLDS, rank_for_points


class BadgeCategory(StrEnum):
    RANK = "rank"
    ACHIEVEMENT = "achievement"
    COMPETITION = "competition"
    ACTIVITY = "activity"


@dataclass(frozen=True)
class BadgeDefinition:
    code: str
    name: str
    description: str
    category: BadgeCategory
    icon: str
    points_threshold: int | None = None


@dataclass(frozen=True)
class BadgeContext:
    points: int = 0
    wins: int = 0
    consecutive_wins: int = 0
    is_tournament_champion: bool = False
    is_tournament_finalist: bool = False
    is_most_active_player: bool = False
    is_monthly_undefeated: bool = False
    is_top_10_general: bool = False
    is_top_10_competition: bool = False
    has_most_watched_game: bool = False


def _badge_code(value: str) -> str:
    return (
        value.lower()
        .replace(" ", "_")
        .replace("'", "")
        .replace("-", "_")
    )


RANK_BADGES = [
    BadgeDefinition(
        code=f"rank_{_badge_code(name)}",
        name=name,
        description=f"Rang atteint avec au moins {threshold} points.",
        category=BadgeCategory.RANK,
        icon=f"{_badge_code(name)}.svg",
        points_threshold=threshold,
    )
    for name, threshold in reversed(RANK_THRESHOLDS)
]

SPECIAL_BADGES = [
    BadgeDefinition("first_win", "Premiere victoire", "Gagner sa premiere partie.", BadgeCategory.ACHIEVEMENT, "first_win.svg"),
    BadgeDefinition("wins_10", "10 victoires", "Atteindre 10 victoires.", BadgeCategory.ACHIEVEMENT, "wins_10.svg"),
    BadgeDefinition("wins_50", "50 victoires", "Atteindre 50 victoires.", BadgeCategory.ACHIEVEMENT, "wins_50.svg"),
    BadgeDefinition("wins_100", "100 victoires", "Atteindre 100 victoires.", BadgeCategory.ACHIEVEMENT, "wins_100.svg"),
    BadgeDefinition("streak_5", "5 victoires consecutives", "Gagner 5 parties consecutives.", BadgeCategory.ACHIEVEMENT, "streak_5.svg"),
    BadgeDefinition("tournament_champion", "Champion de tournoi", "Remporter un tournoi.", BadgeCategory.COMPETITION, "tournament_champion.svg"),
    BadgeDefinition("tournament_finalist", "Finaliste", "Atteindre une finale.", BadgeCategory.COMPETITION, "tournament_finalist.svg"),
    BadgeDefinition("most_active_player", "Joueur le plus actif", "Etre le joueur le plus actif.", BadgeCategory.ACTIVITY, "most_active_player.svg"),
    BadgeDefinition("monthly_undefeated", "Invaincu du mois", "Rester invaincu sur un mois.", BadgeCategory.ACHIEVEMENT, "monthly_undefeated.svg"),
    BadgeDefinition("top_10_general", "Top 10 general", "Entrer dans le top 10 general.", BadgeCategory.COMPETITION, "top_10_general.svg"),
    BadgeDefinition("top_10_competition", "Top 10 competition", "Entrer dans le top 10 d'une competition.", BadgeCategory.COMPETITION, "top_10_competition.svg"),
    BadgeDefinition("most_watched_game", "Partie la plus regardee", "Jouer la partie la plus regardee.", BadgeCategory.ACTIVITY, "most_watched_game.svg"),
]

BADGE_CATALOG = {badge.code: badge for badge in [*RANK_BADGES, *SPECIAL_BADGES]}


def current_rank_badge(context: BadgeContext) -> BadgeDefinition:
    rank_name = rank_for_points(context.points)
    return BADGE_CATALOG[f"rank_{_badge_code(rank_name)}"]


def automatic_badges(context: BadgeContext) -> list[BadgeDefinition]:
    awarded: list[BadgeDefinition] = [current_rank_badge(context)]

    if context.wins >= 1:
        awarded.append(BADGE_CATALOG["first_win"])
    if context.wins >= 10:
        awarded.append(BADGE_CATALOG["wins_10"])
    if context.wins >= 50:
        awarded.append(BADGE_CATALOG["wins_50"])
    if context.wins >= 100:
        awarded.append(BADGE_CATALOG["wins_100"])
    if context.consecutive_wins >= 5:
        awarded.append(BADGE_CATALOG["streak_5"])
    if context.is_tournament_champion:
        awarded.append(BADGE_CATALOG["tournament_champion"])
    if context.is_tournament_finalist:
        awarded.append(BADGE_CATALOG["tournament_finalist"])
    if context.is_most_active_player:
        awarded.append(BADGE_CATALOG["most_active_player"])
    if context.is_monthly_undefeated:
        awarded.append(BADGE_CATALOG["monthly_undefeated"])
    if context.is_top_10_general:
        awarded.append(BADGE_CATALOG["top_10_general"])
    if context.is_top_10_competition:
        awarded.append(BADGE_CATALOG["top_10_competition"])
    if context.has_most_watched_game:
        awarded.append(BADGE_CATALOG["most_watched_game"])

    return awarded


def missing_badges(current_codes: set[str], context: BadgeContext) -> list[BadgeDefinition]:
    return [badge for badge in automatic_badges(context) if badge.code not in current_codes]

