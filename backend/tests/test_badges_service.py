from apps.badges.services.badges import (
    BADGE_CATALOG,
    BadgeContext,
    automatic_badges,
    current_rank_badge,
    missing_badges,
)


def test_catalog_contains_rank_and_special_badges():
    assert "rank_novice_i" in BADGE_CATALOG
    assert "rank_legende" in BADGE_CATALOG
    assert "first_win" in BADGE_CATALOG
    assert "most_watched_game" in BADGE_CATALOG


def test_current_rank_badge_uses_points():
    badge = current_rank_badge(BadgeContext(points=1700))

    assert badge.code == "rank_maitre_du_club"
    assert badge.points_threshold == 1700


def test_automatic_win_badges():
    badges = automatic_badges(BadgeContext(points=120, wins=10, consecutive_wins=5))
    codes = {badge.code for badge in badges}

    assert "rank_apprenti_i" in codes
    assert "first_win" in codes
    assert "wins_10" in codes
    assert "streak_5" in codes
    assert "wins_50" not in codes


def test_automatic_competition_and_activity_badges():
    badges = automatic_badges(
        BadgeContext(
            points=3100,
            wins=100,
            is_tournament_champion=True,
            is_tournament_finalist=True,
            is_most_active_player=True,
            is_monthly_undefeated=True,
            is_top_10_general=True,
            is_top_10_competition=True,
            has_most_watched_game=True,
        )
    )
    codes = {badge.code for badge in badges}

    assert "rank_legende" in codes
    assert "wins_100" in codes
    assert "tournament_champion" in codes
    assert "tournament_finalist" in codes
    assert "most_active_player" in codes
    assert "monthly_undefeated" in codes
    assert "top_10_general" in codes
    assert "top_10_competition" in codes
    assert "most_watched_game" in codes


def test_missing_badges_filters_existing_codes():
    missing = missing_badges(
        {"rank_apprenti_i", "first_win"},
        BadgeContext(points=120, wins=10),
    )

    assert [badge.code for badge in missing] == ["wins_10"]

