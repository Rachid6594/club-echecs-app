import pytest

from apps.tournaments.services.round_robin import (
    RoundRobinError,
    compute_standings,
    generate_round_robin,
    record_result,
)


def test_round_robin_requires_unique_players():
    with pytest.raises(RoundRobinError):
        generate_round_robin(["a"])
    with pytest.raises(RoundRobinError):
        generate_round_robin(["a", "a"])


def test_even_round_robin_generates_all_pairings_once():
    rounds = generate_round_robin(["a", "b", "c", "d"])
    pairings = {
        frozenset([match.white_player_id, match.black_player_id])
        for round_item in rounds
        for match in round_item.matches
    }

    assert len(rounds) == 3
    assert len(pairings) == 6
    assert all(len(round_item.matches) == 2 for round_item in rounds)


def test_odd_round_robin_uses_byes():
    rounds = generate_round_robin(["a", "b", "c"])

    assert len(rounds) == 3
    assert {round_item.bye_player_id for round_item in rounds} == {"a", "b", "c"}
    assert all(len(round_item.matches) == 1 for round_item in rounds)


def test_record_result_validates_scores():
    match = generate_round_robin(["a", "b"])[0].matches[0]

    completed = record_result(match, 1, 0)

    assert completed.white_score == 1
    assert completed.black_score == 0

    with pytest.raises(RoundRobinError):
        record_result(match, 2, 0)


def test_compute_standings_points_and_tiebreakers():
    rounds = generate_round_robin(["a", "b", "c"])
    completed_rounds = []
    for round_item in rounds:
        matches = []
        for match in round_item.matches:
            if {match.white_player_id, match.black_player_id} == {"a", "b"}:
                score = (1, 0) if match.white_player_id == "a" else (0, 1)
            elif {match.white_player_id, match.black_player_id} == {"a", "c"}:
                score = (0.5, 0.5)
            else:
                score = (1, 0) if match.white_player_id == "b" else (0, 1)
            matches.append(record_result(match, *score))
        completed_rounds.append(type(round_item)(round_item.round_number, matches, round_item.bye_player_id))

    standings = compute_standings(completed_rounds)

    assert standings[0].user_id == "a"
    assert standings[0].points == 1.5
    assert standings[0].wins == 1
    assert standings[0].draws == 1

