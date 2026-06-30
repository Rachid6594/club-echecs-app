from dataclasses import dataclass
import math
import random

from apps.rankings.services.ranking import CompetitionBonus, PlayerStanding, apply_competition_bonus


class TournamentError(ValueError):
    pass


@dataclass(frozen=True)
class BracketMatch:
    round_number: int
    match_number: int
    player1_id: str | None
    player2_id: str | None
    winner_id: str | None = None

    @property
    def is_bye(self) -> bool:
        return (self.player1_id is None) != (self.player2_id is None)

    def automatic_winner(self) -> str | None:
        if not self.is_bye:
            return None
        return self.player1_id or self.player2_id


@dataclass(frozen=True)
class BracketRound:
    round_number: int
    matches: list[BracketMatch]


@dataclass
class SingleEliminationBracket:
    players: list[str]
    rounds: list[BracketRound]

    @property
    def champion_id(self) -> str | None:
        final = self.rounds[-1].matches[0]
        return final.winner_id


def bracket_size(player_count: int) -> int:
    if player_count < 2:
        raise TournamentError("Un tournoi elimination directe exige au moins 2 joueurs.")
    return 2 ** math.ceil(math.log2(player_count))


def generate_random_draw(player_ids: list[str], seed: int | None = None) -> list[str | None]:
    if len(set(player_ids)) != len(player_ids):
        raise TournamentError("Les joueurs inscrits doivent etre uniques.")
    size = bracket_size(len(player_ids))
    rng = random.Random(seed)
    draw = list(player_ids)
    rng.shuffle(draw)
    return [*draw, *([None] * (size - len(draw)))]


def generate_first_round(player_ids: list[str], seed: int | None = None) -> SingleEliminationBracket:
    draw = generate_random_draw(player_ids, seed=seed)
    matches = []
    for index in range(0, len(draw), 2):
        match_number = index // 2 + 1
        match = BracketMatch(1, match_number, draw[index], draw[index + 1])
        matches.append(match)
    return SingleEliminationBracket(players=player_ids, rounds=[BracketRound(1, matches)])


def complete_round(bracket: SingleEliminationBracket, winners: dict[int, str]) -> SingleEliminationBracket:
    current_round = bracket.rounds[-1]
    completed_matches: list[BracketMatch] = []
    advancing: list[str] = []

    for match in current_round.matches:
        automatic_winner = match.automatic_winner()
        winner = automatic_winner or winners.get(match.match_number)
        valid_players = {player for player in [match.player1_id, match.player2_id] if player is not None}
        if winner is None:
            raise TournamentError(f"Vainqueur manquant pour le match {match.match_number}.")
        if winner not in valid_players:
            raise TournamentError(f"Vainqueur invalide pour le match {match.match_number}.")
        completed_matches.append(
            BracketMatch(
                match.round_number,
                match.match_number,
                match.player1_id,
                match.player2_id,
                winner,
            )
        )
        advancing.append(winner)

    bracket.rounds[-1] = BracketRound(current_round.round_number, completed_matches)
    if len(advancing) == 1:
        return bracket

    next_matches = []
    for index in range(0, len(advancing), 2):
        next_matches.append(
            BracketMatch(
                current_round.round_number + 1,
                index // 2 + 1,
                advancing[index],
                advancing[index + 1] if index + 1 < len(advancing) else None,
            )
        )
    bracket.rounds.append(BracketRound(current_round.round_number + 1, next_matches))
    return bracket


def competition_bonus_standings(
    *,
    champion_id: str,
    finalist_id: str | None,
    semi_finalist_ids: list[str],
    participant_ids: list[str],
) -> dict[str, PlayerStanding]:
    standings = {user_id: PlayerStanding(user_id=user_id) for user_id in participant_ids}
    for user_id in participant_ids:
        standings[user_id] = apply_competition_bonus(standings[user_id], CompetitionBonus.PARTICIPATION)
    standings[champion_id] = apply_competition_bonus(standings[champion_id], CompetitionBonus.CHAMPION)
    if finalist_id:
        standings[finalist_id] = apply_competition_bonus(standings[finalist_id], CompetitionBonus.FINALIST)
    for user_id in semi_finalist_ids:
        standings[user_id] = apply_competition_bonus(standings[user_id], CompetitionBonus.SEMI_FINALIST)
    return standings

