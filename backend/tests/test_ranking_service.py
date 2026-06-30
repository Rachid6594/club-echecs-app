import pytest

from apps.rankings.services.ranking import (
    CompetitionBonus,
    MatchOutcome,
    PlayerStanding,
    apply_competition_bonus,
    apply_match_result,
    player_stats,
    rank_for_points,
    recompute_standings,
    sort_standings,
    top_10_general,
)


def test_match_points_rules():
    standing = PlayerStanding(user_id="u1")

    standing = apply_match_result(standing, MatchOutcome.WIN)
    standing = apply_match_result(standing, MatchOutcome.DRAW)
    standing = apply_match_result(standing, MatchOutcome.LOSS)

    assert standing.points == 4
    assert standing.wins == 1
    assert standing.draws == 1
    assert standing.losses == 1
    assert standing.games_played == 3


def test_resignation_and_timeout_use_standard_points():
    winner = apply_match_result(PlayerStanding("winner"), MatchOutcome.RESIGNATION_WIN)
    loser = apply_match_result(PlayerStanding("loser"), MatchOutcome.TIMEOUT_LOSS)

    assert winner.points == 3
    assert winner.wins == 1
    assert loser.points == 0
    assert loser.losses == 1


def test_competition_bonus_points():
    standing = PlayerStanding(user_id="u1", points=9)
    standing = apply_competition_bonus(standing, CompetitionBonus.CHAMPION)
    standing = apply_competition_bonus(standing, CompetitionBonus.PARTICIPATION)

    assert standing.bonus_points == 55
    assert standing.total_points == 64


@pytest.mark.parametrize(
    ("points", "rank"),
    [
        (0, "Novice I"),
        (30, "Novice II"),
        (60, "Novice III"),
        (100, "Apprenti I"),
        (160, "Apprenti II"),
        (230, "Apprenti III"),
        (320, "Intermediaire I"),
        (450, "Intermediaire II"),
        (600, "Intermediaire III"),
        (800, "Stratege I"),
        (1050, "Stratege II"),
        (1350, "Stratege III"),
        (1700, "Maitre du Club"),
        (2200, "Grand Maitre du Club"),
        (3000, "Legende"),
    ],
)
def test_rank_thresholds(points, rank):
    assert rank_for_points(points) == rank


def test_rank_rejects_negative_points():
    with pytest.raises(ValueError):
        rank_for_points(-1)


def test_recompute_standings_and_sorting():
    standings = recompute_standings(
        {
            "alice": [MatchOutcome.WIN, MatchOutcome.DRAW],
            "bob": [MatchOutcome.WIN, MatchOutcome.LOSS],
            "charlie": [MatchOutcome.DRAW, MatchOutcome.DRAW, MatchOutcome.DRAW],
        }
    )

    assert [standing.user_id for standing in standings] == ["alice", "bob", "charlie"]
    assert standings[0].total_points == 4


def test_sort_tie_breakers_use_wins_then_losses_then_user_id():
    standings = [
        PlayerStanding(user_id="b", points=6, wins=1, losses=0),
        PlayerStanding(user_id="a", points=6, wins=2, losses=1),
        PlayerStanding(user_id="c", points=6, wins=1, losses=1),
    ]

    assert [standing.user_id for standing in sort_standings(standings)] == ["a", "b", "c"]


def test_top_10_general_limits_results():
    standings = [PlayerStanding(user_id=f"u{i:02d}", points=i) for i in range(20)]

    top = top_10_general(standings)

    assert len(top) == 10
    assert top[0].user_id == "u19"
    assert top[-1].user_id == "u10"


def test_player_stats_payload():
    standing = PlayerStanding(user_id="u1", points=27, wins=9)
    standing = apply_competition_bonus(standing, CompetitionBonus.PARTICIPATION)

    stats = player_stats(standing)

    assert stats["points"] == 32
    assert stats["match_points"] == 27
    assert stats["bonus_points"] == 5
    assert stats["rank_name"] == "Novice II"
