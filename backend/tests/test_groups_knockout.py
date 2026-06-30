import pytest

from apps.tournaments.services.groups_knockout import (
    GroupsKnockoutError,
    draw_groups,
    generate_final_phase,
    qualify_from_groups,
)
from apps.tournaments.services.round_robin import record_result


def complete_group_with_first_player_winning(group):
    completed_rounds = []
    preferred = group.player_ids[0]
    for round_item in group.rounds:
        matches = []
        for match in round_item.matches:
            if match.white_player_id == preferred:
                score = (1, 0)
            elif match.black_player_id == preferred:
                score = (0, 1)
            else:
                score = (0.5, 0.5)
            matches.append(record_result(match, *score))
        completed_rounds.append(type(round_item)(round_item.round_number, matches, round_item.bye_player_id))
    return completed_rounds


def test_draw_groups_validates_inputs():
    with pytest.raises(GroupsKnockoutError):
        draw_groups(["a", "b", "c"], group_count=2, qualifiers_per_group=1)
    with pytest.raises(GroupsKnockoutError):
        draw_groups(["a", "b", "c", "d"], group_count=1, qualifiers_per_group=1)
    with pytest.raises(GroupsKnockoutError):
        draw_groups(["a", "a", "c", "d"], group_count=2, qualifiers_per_group=1)


def test_draw_groups_distributes_players_and_generates_group_matches():
    plan = draw_groups(["a", "b", "c", "d", "e", "f"], group_count=2, qualifiers_per_group=2, seed=7)

    assert [group.name for group in plan.groups] == ["A", "B"]
    assert sorted(len(group.player_ids) for group in plan.groups) == [3, 3]
    assert all(group.rounds for group in plan.groups)


def test_qualify_from_groups_selects_top_players_by_group():
    plan = draw_groups(["a", "b", "c", "d", "e", "f"], group_count=2, qualifiers_per_group=1, seed=3)
    completed = {group.name: complete_group_with_first_player_winning(group) for group in plan.groups}

    qualifiers = qualify_from_groups(completed, qualifiers_per_group=1)

    assert qualifiers == [plan.groups[0].player_ids[0], plan.groups[1].player_ids[0]]


def test_generate_final_phase_from_qualifiers():
    bracket = generate_final_phase(["a", "b", "c", "d"], seed=1)

    assert len(bracket.rounds[0].matches) == 2


def test_generate_final_phase_rejects_too_few_qualifiers():
    with pytest.raises(GroupsKnockoutError):
        generate_final_phase(["a"])

