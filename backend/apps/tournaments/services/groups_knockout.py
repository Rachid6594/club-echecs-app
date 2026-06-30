from dataclasses import dataclass
import random

from apps.tournaments.services.round_robin import CompetitionStanding, RoundRobinRound, compute_standings, generate_round_robin
from apps.tournaments.services.single_elimination import SingleEliminationBracket, TournamentError, generate_first_round


class GroupsKnockoutError(ValueError):
    pass


@dataclass(frozen=True)
class TournamentGroupPlan:
    name: str
    player_ids: list[str]
    rounds: list[RoundRobinRound]


@dataclass(frozen=True)
class GroupsKnockoutPlan:
    groups: list[TournamentGroupPlan]
    qualifiers_per_group: int


def draw_groups(
    player_ids: list[str],
    *,
    group_count: int,
    qualifiers_per_group: int,
    seed: int | None = None,
) -> GroupsKnockoutPlan:
    if len(player_ids) < 4:
        raise GroupsKnockoutError("Le format groupes + phase finale exige au moins 4 joueurs.")
    if group_count < 2:
        raise GroupsKnockoutError("Il faut au moins 2 groupes.")
    if qualifiers_per_group < 1:
        raise GroupsKnockoutError("Il faut au moins 1 qualifie par groupe.")
    if len(set(player_ids)) != len(player_ids):
        raise GroupsKnockoutError("Les joueurs doivent etre uniques.")
    if group_count > len(player_ids):
        raise GroupsKnockoutError("Le nombre de groupes ne peut pas depasser le nombre de joueurs.")

    shuffled = list(player_ids)
    random.Random(seed).shuffle(shuffled)
    buckets = [[] for _ in range(group_count)]
    for index, player_id in enumerate(shuffled):
        buckets[index % group_count].append(player_id)

    groups = [
        TournamentGroupPlan(
            name=chr(ord("A") + index),
            player_ids=bucket,
            rounds=generate_round_robin(bucket),
        )
        for index, bucket in enumerate(buckets)
    ]
    return GroupsKnockoutPlan(groups=groups, qualifiers_per_group=qualifiers_per_group)


def qualify_from_groups(
    group_rounds: dict[str, list[RoundRobinRound]],
    *,
    qualifiers_per_group: int,
) -> list[str]:
    if qualifiers_per_group < 1:
        raise GroupsKnockoutError("Il faut au moins 1 qualifie par groupe.")

    qualifiers: list[str] = []
    for group_name in sorted(group_rounds):
        standings = compute_standings(group_rounds[group_name])
        if len(standings) < qualifiers_per_group:
            raise GroupsKnockoutError(f"Pas assez de joueurs dans le groupe {group_name}.")
        qualifiers.extend([standing.user_id for standing in standings[:qualifiers_per_group]])
    return qualifiers


def generate_final_phase(qualifier_ids: list[str], seed: int | None = None) -> SingleEliminationBracket:
    try:
        return generate_first_round(qualifier_ids, seed=seed)
    except TournamentError as exc:
        raise GroupsKnockoutError(str(exc)) from exc


def group_standings(rounds: list[RoundRobinRound]) -> list[CompetitionStanding]:
    return compute_standings(rounds)

