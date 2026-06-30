import json
import uuid

from django.core import signing
from django.contrib.auth.hashers import check_password, make_password
from django.db import DatabaseError, connection, transaction
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView


def dictfetchall(cursor):
    columns = [column[0] for column in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def db_error_response(error: Exception):
    return Response(
        {
            "detail": "Base Supabase non connectee ou schema indisponible.",
            "error": str(error),
        },
        status=status.HTTP_503_SERVICE_UNAVAILABLE,
    )


def log_admin_action(action: str, entity_type: str, entity_id: uuid.UUID | None = None, metadata: dict | None = None):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            insert into public.audit_logs (id, actor_id, action, entity_type, entity_id, metadata, created_at)
            values (%s, null, %s, %s, %s, %s::jsonb, now())
            """,
            [uuid.uuid4(), action, entity_type, entity_id, json.dumps(metadata or {})],
        )


def fetch_dashboard_payload():
    with connection.cursor() as cursor:
        cursor.execute(
            """
            select
              (select count(*) from public.club_members where status = 'active')::int as active_members,
              (select count(*) from public.matches where status in ('scheduled', 'active', 'disputed'))::int as open_matches,
              (select count(*) from public.tournaments where status in ('registration_open', 'active'))::int as open_tournaments,
              (select count(*) from public.disputes where status in ('open', 'under_review'))::int as open_disputes,
              (select count(*) from public.badges where is_active = true)::int as active_badges
            """
        )
        metrics = dictfetchall(cursor)[0]

        cursor.execute(
            """
            select
              cm.id,
              cm.member_number,
              cm.status,
              cm.joined_at,
              au.username,
              au.email,
              up.display_name,
              coalesce(r.points, up.total_points, 0)::int as points,
              coalesce(r.rank_name, 'Non classe') as rank_name
            from public.club_members cm
            join public.app_users au on au.id = cm.user_id
            left join public.user_profiles up on up.user_id = au.id
            left join public.rankings r on r.user_id = au.id
            order by cm.created_at desc
            limit 8
            """
        )
        members = dictfetchall(cursor)

        cursor.execute(
            """
            select id, name, format, status, starts_at, max_players, created_at
            from public.tournaments
            order by created_at desc
            limit 8
            """
        )
        tournaments = dictfetchall(cursor)

        cursor.execute(
            """
            select id, status, reason, resolution, created_at, resolved_at
            from public.disputes
            order by created_at desc
            limit 8
            """
        )
        disputes = dictfetchall(cursor)

        cursor.execute(
            """
            select id, action, entity_type, entity_id, metadata, created_at
            from public.audit_logs
            order by created_at desc
            limit 8
            """
        )
        audit_logs = dictfetchall(cursor)

    return {
        "metrics": metrics,
        "members": members,
        "tournaments": tournaments,
        "disputes": disputes,
        "audit_logs": audit_logs,
    }


class SupabaseAdminAPIView(APIView):
    permission_classes = [AllowAny]


def serialize_app_user(row: dict):
    return {
        "id": row["id"],
        "username": row["username"],
        "email": row["email"],
        "role": row["role"],
        "display_name": row.get("display_name"),
        "rank_name": row.get("rank_name", "Novice I"),
        "points": row.get("points", 0),
    }


class AppRegisterView(SupabaseAdminAPIView):
    def post(self, request):
        username = (request.data.get("username") or "").strip()
        email = (request.data.get("email") or "").strip().lower()
        password = request.data.get("password") or ""
        display_name = (request.data.get("display_name") or username).strip()

        if len(username) < 3:
            return Response({"detail": "Le nom utilisateur doit contenir au moins 3 caracteres."}, status=status.HTTP_400_BAD_REQUEST)
        if len(password) < 8:
            return Response({"detail": "Le mot de passe doit contenir au moins 8 caracteres."}, status=status.HTTP_400_BAD_REQUEST)
        if "@" not in email:
            return Response({"detail": "Email invalide."}, status=status.HTTP_400_BAD_REQUEST)

        user_id = uuid.uuid4()
        profile_id = uuid.uuid4()
        member_id = uuid.uuid4()
        ranking_id = uuid.uuid4()

        try:
            with transaction.atomic():
                with connection.cursor() as cursor:
                    cursor.execute(
                        """
                        insert into public.app_users (
                          id, email, username, role, is_active, password_hash, created_at, updated_at
                        )
                        values (%s, %s, %s, 'player', true, %s, now(), now())
                        returning id, email, username, role
                        """,
                        [user_id, email, username, make_password(password)],
                    )
                    user = dictfetchall(cursor)[0]
                    cursor.execute(
                        """
                        insert into public.user_profiles (
                          id, user_id, display_name, total_points, total_wins, total_draws,
                          total_losses, current_streak, best_streak, created_at, updated_at
                        )
                        values (%s, %s, %s, 0, 0, 0, 0, 0, 0, now(), now())
                        """,
                        [profile_id, user_id, display_name],
                    )
                    cursor.execute(
                        """
                        insert into public.club_members (
                          id, user_id, status, joined_at, notes, created_at, updated_at
                        )
                        values (%s, %s, 'active', now(), '', now(), now())
                        """,
                        [member_id, user_id],
                    )
                    cursor.execute(
                        """
                        insert into public.rankings (
                          id, user_id, points, wins, draws, losses, games_played,
                          rank_position, rank_name, recomputed_at, updated_at
                        )
                        values (%s, %s, 0, 0, 0, 0, 0, null, 'Novice I', now(), now())
                        """,
                        [ranking_id, user_id],
                    )
                log_admin_action("register_user", "app_user", user_id, {"username": username})
            user.update({"display_name": display_name, "rank_name": "Novice I", "points": 0})
            token = signing.dumps({"user_id": str(user_id), "role": "player"}, salt="app-auth")
            return Response({"user": serialize_app_user(user), "tokens": {"access": token}}, status=status.HTTP_201_CREATED)
        except DatabaseError as error:
            message = str(error)
            if "duplicate" in message.lower() or "unique" in message.lower():
                return Response({"detail": "Email ou nom utilisateur deja utilise."}, status=status.HTTP_400_BAD_REQUEST)
            return db_error_response(error)


class AppLoginView(SupabaseAdminAPIView):
    def post(self, request):
        email = (request.data.get("email") or "").strip().lower()
        password = request.data.get("password") or ""
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    select au.id, au.username, au.email, au.role, au.password_hash,
                           up.display_name,
                           coalesce(r.rank_name, 'Novice I') as rank_name,
                           coalesce(r.points, 0)::int as points
                    from public.app_users au
                    left join public.user_profiles up on up.user_id = au.id
                    left join public.rankings r on r.user_id = au.id
                    where lower(au.email) = %s and au.is_active = true
                    limit 1
                    """,
                    [email],
                )
                rows = dictfetchall(cursor)
                if not rows or not rows[0].get("password_hash") or not check_password(password, rows[0]["password_hash"]):
                    return Response({"detail": "Identifiants invalides."}, status=status.HTTP_400_BAD_REQUEST)
                cursor.execute("update public.app_users set last_login_at = now(), updated_at = now() where id = %s", [rows[0]["id"]])
            token = signing.dumps({"user_id": str(rows[0]["id"]), "role": rows[0]["role"]}, salt="app-auth")
            return Response({"user": serialize_app_user(rows[0]), "tokens": {"access": token}})
        except DatabaseError as error:
            return db_error_response(error)


class AdminDashboardView(SupabaseAdminAPIView):
    def get(self, request):
        try:
            return Response(fetch_dashboard_payload())
        except DatabaseError as error:
            return db_error_response(error)


class AdminMemberListCreateView(SupabaseAdminAPIView):
    def get(self, request):
        try:
            search = request.query_params.get("search")
            params = []
            where = ""
            if search:
                where = """
                where au.username ilike %s
                   or au.email ilike %s
                   or up.display_name ilike %s
                """
                term = f"%{search}%"
                params = [term, term, term]

            with connection.cursor() as cursor:
                cursor.execute(
                    f"""
                    select
                      cm.id,
                      cm.member_number,
                      cm.status,
                      cm.joined_at,
                      au.id as user_id,
                      au.username,
                      au.email,
                      au.role,
                      au.is_active,
                      up.display_name,
                      up.country_code,
                      coalesce(r.points, up.total_points, 0)::int as points,
                      coalesce(r.wins, up.total_wins, 0)::int as wins,
                      coalesce(r.draws, up.total_draws, 0)::int as draws,
                      coalesce(r.losses, up.total_losses, 0)::int as losses,
                      coalesce(r.games_played, up.total_wins + up.total_draws + up.total_losses, 0)::int as games_played,
                      coalesce(r.rank_name, 'Non classe') as rank_name
                    from public.club_members cm
                    join public.app_users au on au.id = cm.user_id
                    left join public.user_profiles up on up.user_id = au.id
                    left join public.rankings r on r.user_id = au.id
                    {where}
                    order by cm.created_at desc
                    limit 100
                    """,
                    params,
                )
                return Response({"results": dictfetchall(cursor)})
        except DatabaseError as error:
            return db_error_response(error)

    def post(self, request):
        username = (request.data.get("username") or "").strip()
        email = (request.data.get("email") or "").strip().lower()
        display_name = (request.data.get("display_name") or username).strip()
        role = request.data.get("role") or "player"
        member_number = (request.data.get("member_number") or "").strip() or None

        if not username or not email:
            return Response({"detail": "username et email sont requis."}, status=status.HTTP_400_BAD_REQUEST)

        user_id = uuid.uuid4()
        member_id = uuid.uuid4()
        ranking_id = uuid.uuid4()
        profile_id = uuid.uuid4()

        try:
            with transaction.atomic():
                with connection.cursor() as cursor:
                    cursor.execute(
                        """
                        insert into public.app_users (id, email, username, role, is_active, created_at, updated_at)
                        values (%s, %s, %s, %s, true, now(), now())
                        returning id, email, username, role, is_active, created_at
                        """,
                        [user_id, email, username, role],
                    )
                    user = dictfetchall(cursor)[0]

                    cursor.execute(
                        """
                        insert into public.user_profiles (
                          id, user_id, display_name, total_points, total_wins, total_draws,
                          total_losses, current_streak, best_streak, created_at, updated_at
                        )
                        values (%s, %s, %s, 0, 0, 0, 0, 0, 0, now(), now())
                        """,
                        [profile_id, user_id, display_name],
                    )
                    cursor.execute(
                        """
                        insert into public.club_members (
                          id, user_id, member_number, status, joined_at, notes, created_at, updated_at
                        )
                        values (%s, %s, %s, 'active', now(), '', now(), now())
                        returning id, member_number, status, joined_at
                        """,
                        [member_id, user_id, member_number],
                    )
                    member = dictfetchall(cursor)[0]

                    cursor.execute(
                        """
                        insert into public.rankings (
                          id, user_id, points, wins, draws, losses, games_played,
                          rank_position, rank_name, recomputed_at, updated_at
                        )
                        values (%s, %s, 0, 0, 0, 0, 0, null, 'Novice I', now(), now())
                        """,
                        [ranking_id, user_id],
                    )
                log_admin_action("create_member", "club_member", member_id, {"username": username})
            return Response({"user": user, "member": member}, status=status.HTTP_201_CREATED)
        except DatabaseError as error:
            return db_error_response(error)


class AdminTournamentListCreateView(SupabaseAdminAPIView):
    def get(self, request):
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    select
                      t.id,
                      t.name,
                      t.description,
                      t.format,
                      t.status,
                      t.starts_at,
                      t.ends_at,
                      t.max_players,
                      t.time_control_initial_seconds,
                      t.time_control_increment_seconds,
                      t.created_at,
                      au.username as created_by_username
                    from public.tournaments t
                    left join public.app_users au on au.id = t.created_by_id
                    order by t.created_at desc
                    limit 100
                    """
                )
                return Response({"results": dictfetchall(cursor)})
        except DatabaseError as error:
            return db_error_response(error)

    def post(self, request):
        name = (request.data.get("name") or "").strip()
        tournament_format = request.data.get("format") or "single_elimination"
        max_players = request.data.get("max_players") or None

        if not name:
            return Response({"detail": "Le nom du tournoi est requis."}, status=status.HTTP_400_BAD_REQUEST)

        tournament_id = uuid.uuid4()
        try:
            with transaction.atomic():
                with connection.cursor() as cursor:
                    cursor.execute(
                        """
                        select id
                        from public.app_users
                        where role in ('admin', 'super_admin')
                        order by created_at asc
                        limit 1
                        """
                    )
                    creator_rows = dictfetchall(cursor)
                    if not creator_rows:
                        return Response(
                            {"detail": "Cree d'abord un membre admin pour creer un tournoi."},
                            status=status.HTTP_400_BAD_REQUEST,
                        )

                    cursor.execute(
                        """
                        insert into public.tournaments (
                          id, created_by_id, name, description, format, status,
                          max_players, time_control_initial_seconds,
                          time_control_increment_seconds, settings, created_at, updated_at
                        )
                        values (%s, %s, %s, %s, %s, 'registration_open', %s, 600, 0, '{}'::jsonb, now(), now())
                        returning id, name, format, status, max_players, created_at
                        """,
                        [
                            tournament_id,
                            creator_rows[0]["id"],
                            name,
                            request.data.get("description") or "",
                            tournament_format,
                            max_players,
                        ],
                    )
                    tournament = dictfetchall(cursor)[0]
                log_admin_action("create_tournament", "tournament", tournament_id, {"name": name})
            return Response(tournament, status=status.HTTP_201_CREATED)
        except DatabaseError as error:
            return db_error_response(error)


class AdminDisputeListView(SupabaseAdminAPIView):
    def get(self, request):
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    select d.id, d.status, d.reason, d.resolution, d.created_at, d.resolved_at,
                           opener.username as opened_by_username,
                           admin_user.username as assigned_admin_username
                    from public.disputes d
                    join public.app_users opener on opener.id = d.opened_by_id
                    left join public.app_users admin_user on admin_user.id = d.assigned_admin_id
                    order by d.created_at desc
                    limit 100
                    """
                )
                return Response({"results": dictfetchall(cursor)})
        except DatabaseError as error:
            return db_error_response(error)


class AdminLiveMatchListView(SupabaseAdminAPIView):
    def get(self, request):
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    select m.id, m.status, m.scheduled_at, m.white_score, m.black_score,
                           white_user.username as white_username,
                           black_user.username as black_username,
                           t.name as tournament_name
                    from public.matches m
                    left join public.app_users white_user on white_user.id = m.white_player_id
                    left join public.app_users black_user on black_user.id = m.black_player_id
                    left join public.tournaments t on t.id = m.tournament_id
                    where m.status in ('scheduled', 'active', 'disputed')
                    order by m.scheduled_at nulls last, m.created_at desc
                    limit 100
                    """
                )
                return Response({"results": dictfetchall(cursor)})
        except DatabaseError as error:
            return db_error_response(error)


class AdminRankingListView(SupabaseAdminAPIView):
    def get(self, request):
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    select r.id, r.user_id, r.points, r.wins, r.draws, r.losses,
                           r.games_played, r.rank_position, r.rank_name,
                           au.username, up.display_name
                    from public.rankings r
                    join public.app_users au on au.id = r.user_id
                    left join public.user_profiles up on up.user_id = au.id
                    order by r.points desc, r.wins desc, au.username asc
                    limit 100
                    """
                )
                return Response({"results": dictfetchall(cursor)})
        except DatabaseError as error:
            return db_error_response(error)


class AdminNotificationListView(SupabaseAdminAPIView):
    def get(self, request):
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    select n.id, n.type, n.title, n.body, (n.read_at is not null) as is_read, n.created_at,
                           au.username
                    from public.notifications n
                    left join public.app_users au on au.id = n.user_id
                    order by n.created_at desc
                    limit 100
                    """
                )
                return Response({"results": dictfetchall(cursor)})
        except DatabaseError as error:
            return db_error_response(error)


class AdminBadgeListView(SupabaseAdminAPIView):
    def get(self, request):
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    select id, code, name, description, category, icon_path, points_threshold, sort_order, is_active
                    from public.badges
                    order by sort_order asc, name asc
                    """
                )
                return Response({"results": dictfetchall(cursor)})
        except DatabaseError as error:
            return db_error_response(error)


class AdminAuditLogListView(SupabaseAdminAPIView):
    def get(self, request):
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    select l.id, l.action, l.entity_type, l.entity_id, l.metadata, l.created_at,
                           au.username as actor_username
                    from public.audit_logs l
                    left join public.app_users au on au.id = l.actor_id
                    order by l.created_at desc
                    limit 100
                    """
                )
                return Response({"results": dictfetchall(cursor)})
        except DatabaseError as error:
            return db_error_response(error)
