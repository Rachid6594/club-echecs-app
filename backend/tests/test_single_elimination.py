import pytest

from apps.tournaments.services.single_elimination import (
    TournamentError,
    bracket_size,
    competition_bonus_standings,
    complete_round,
    generate_first_round,
    generate_random_draw,
)


def test_bracket_size_requires_at_least_two_players():
    assert bracket_size(2) == 2
    assert bracket_size(3) == 4
    assert bracket_size(9) == 16

    with pytest.raises(TournamentError):
        bracket_size(1)


def test_random_draw_is_seeded_and_adds_byes():
    draw1 = generate_random_draw(["a", "b", "c"], seed=42)
    draw2 = generate_random_draw(["a", "b", "c"], seed=42)

    assert draw1 == draw2
    assert len(draw1) == 4
    assert draw1.count(None) == 1


def test_duplicate_players_are_rejected():
    with pytest.raises(TournamentError):
        generate_random_draw(["a", "a"])


def test_first_round_generation():
    bracket = generate_first_round(["a", "b", "c", "d"], seed=1)

    assert len(bracket.rounds) == 1
    assert len(bracket.rounds[0].matches) == 2
    assert bracket.champion_id is None


def test_complete_round_advances_winners_and_byes():
    bracket = generate_first_round(["a", "b", "c"], seed=2)
    first_round = bracket.rounds[0]
    winners = {}
    for match in first_round.matches:
        if not match.is_bye:
            winners[match.match_number] = match.player1_id

    bracket = complete_round(bracket, winners)

    assert len(bracket.rounds) == 2
    assert len(bracket.rounds[1].matches) == 1


def test_invalid_winner_is_rejected():
    bracket = generate_first_round(["a", "b"], seed=1)

    with pytest.raises(TournamentError):
        complete_round(bracket, {1: "z"})


def test_champion_after_final():
    bracket = generate_first_round(["a", "b"], seed=1)
    final = bracket.rounds[0].matches[0]
    champion = final.player1_id

    bracket = complete_round(bracket, {1: champion})

    assert bracket.champion_id == champion


def test_competition_bonus_standings():
    standings = competition_bonus_standings(
        champion_id="a",
        finalist_id="b",
        semi_finalist_ids=["c", "d"],
        participant_ids=["a", "b", "c", "d", "e"],
    )

    assert standings["a"].bonus_points == 55
    assert standings["b"].bonus_points == 35
    assert standings["c"].bonus_points == 20
    assert standings["d"].bonus_points == 20
    assert standings["e"].bonus_points == 5

