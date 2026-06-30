from dataclasses import dataclass


class RoundRobinError(ValueError):
    pass


@dataclass(frozen=True)
class RoundRobinMatch:
    round_number: int
    board_number: int
    white_player_id: str
    black_player_id: str
    white_score: float | None = None
    black_score: float | None = None

    @property
    def is_completed(self) -> bool:
        return self.white_score is not None and self.black_score is not None


@dataclass(frozen=True)
class RoundRobinRound:
    round_number: int
    matches: list[RoundRobinMatch]
    bye_player_id: str | None = None


@dataclass(frozen=True)
class CompetitionStanding:
    user_id: str
    points: float = 0
    wins: int = 0
    draws: int = 0
    losses: int = 0
    games_played: int = 0
    sonneborn_berger: float = 0


def generate_round_robin(player_ids: list[str]) -> list[RoundRobinRound]:
    if len(player_ids) < 2:
        raise RoundRobinError("Un championnat exige au moins 2 joueurs.")
    if len(set(player_ids)) != len(player_ids):
        raise RoundRobinError("Les joueurs doivent etre uniques.")

    players: list[str | None] = list(player_ids)
    if len(players) % 2 == 1:
        players.append(None)

    rounds: list[RoundRobinRound] = []
    player_count = len(players)
    half = player_count // 2

    for round_index in range(player_count - 1):
        matches: list[RoundRobinMatch] = []
        bye_player_id = None
        for board_index in range(half):
            player_a = players[board_index]
            player_b = players[player_count - 1 - board_index]
            if player_a is None or player_b is None:
                bye_player_id = player_a or player_b
                continue

            if round_index % 2 == 0:
                white, black = player_a, player_b
            else:
                white, black = player_b, player_a
            matches.append(RoundRobinMatch(round_index + 1, len(matches) + 1, white, black))

        rounds.append(RoundRobinRound(round_index + 1, matches, bye_player_id))
        players = [players[0], players[-1], *players[1:-1]]

    return rounds


def record_result(match: RoundRobinMatch, white_score: float, black_score: float) -> RoundRobinMatch:
    if (white_score, black_score) not in {(1, 0), (0, 1), (0.5, 0.5)}:
        raise RoundRobinError("Score invalide pour un match round-robin.")
    return RoundRobinMatch(
        match.round_number,
        match.board_number,
        match.white_player_id,
        match.black_player_id,
        white_score,
        black_score,
    )


def compute_standings(rounds: list[RoundRobinRound]) -> list[CompetitionStanding]:
    raw: dict[str, dict] = {}
    head_to_head_scores: dict[str, list[tuple[str, float]]] = {}

    for round_item in rounds:
        for match in round_item.matches:
            for player_id in [match.white_player_id, match.black_player_id]:
                raw.setdefault(player_id, {"points": 0.0, "wins": 0, "draws": 0, "losses": 0, "games_played": 0})
                head_to_head_scores.setdefault(player_id, [])
            if not match.is_completed:
                continue

            raw[match.white_player_id]["points"] += match.white_score
            raw[match.black_player_id]["points"] += match.black_score
            raw[match.white_player_id]["games_played"] += 1
            raw[match.black_player_id]["games_played"] += 1
            head_to_head_scores[match.white_player_id].append((match.black_player_id, match.white_score))
            head_to_head_scores[match.black_player_id].append((match.white_player_id, match.black_score))

            if match.white_score == match.black_score:
                raw[match.white_player_id]["draws"] += 1
                raw[match.black_player_id]["draws"] += 1
            elif match.white_score > match.black_score:
                raw[match.white_player_id]["wins"] += 1
                raw[match.black_player_id]["losses"] += 1
            else:
                raw[match.black_player_id]["wins"] += 1
                raw[match.white_player_id]["losses"] += 1

    standings: list[CompetitionStanding] = []
    for user_id, values in raw.items():
        sb = sum(raw[opponent]["points"] * score for opponent, score in head_to_head_scores[user_id])
        standings.append(
            CompetitionStanding(
                user_id=user_id,
                points=values["points"],
                wins=values["wins"],
                draws=values["draws"],
                losses=values["losses"],
                games_played=values["games_played"],
                sonneborn_berger=sb,
            )
        )

    return sorted(
        standings,
        key=lambda standing: (
            -standing.points,
            -standing.wins,
            -standing.sonneborn_berger,
            standing.losses,
            standing.user_id,
        ),
    )

