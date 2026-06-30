-- Sprint 01 - Initial Row Level Security policies.
-- These policies protect direct Supabase access. Django service-role access
-- remains responsible for authoritative validation and admin operations.

create or replace function public.current_app_user_id()
returns uuid
language sql
stable
as $$
  select id
  from public.app_users
  where auth_user_id = auth.uid()
  limit 1
$$;

create or replace function public.current_app_role()
returns public.user_role
language sql
stable
as $$
  select coalesce(
    (auth.jwt() -> 'app_metadata' ->> 'role')::public.user_role,
    (select role from public.app_users where auth_user_id = auth.uid() limit 1),
    'player'::public.user_role
  )
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
as $$
  select public.current_app_role() in ('admin', 'super_admin')
$$;

alter table public.app_users enable row level security;
alter table public.user_profiles enable row level security;
alter table public.club_members enable row level security;
alter table public.tournaments enable row level security;
alter table public.tournament_registrations enable row level security;
alter table public.tournament_stages enable row level security;
alter table public.tournament_groups enable row level security;
alter table public.tournament_brackets enable row level security;
alter table public.matches enable row level security;
alter table public.games enable row level security;
alter table public.moves enable row level security;
alter table public.game_clocks enable row level security;
alter table public.invitations enable row level security;
alter table public.spectator_sessions enable row level security;
alter table public.game_views enable row level security;
alter table public.rankings enable row level security;
alter table public.competition_rankings enable row level security;
alter table public.badges enable row level security;
alter table public.user_badges enable row level security;
alter table public.notifications enable row level security;
alter table public.audit_logs enable row level security;
alter table public.disputes enable row level security;
alter table public.admin_corrections enable row level security;

create policy app_users_select_self_or_admin
on public.app_users for select
using (id = public.current_app_user_id() or public.is_admin());

create policy user_profiles_select_members
on public.user_profiles for select
using (
  exists (
    select 1 from public.club_members cm
    where cm.user_id = user_profiles.user_id
      and cm.status = 'active'
  )
  or user_id = public.current_app_user_id()
  or public.is_admin()
);

create policy user_profiles_update_self
on public.user_profiles for update
using (user_id = public.current_app_user_id())
with check (user_id = public.current_app_user_id());

create policy club_members_select_active_or_self_or_admin
on public.club_members for select
using (
  status = 'active'
  or user_id = public.current_app_user_id()
  or public.is_admin()
);

create policy tournaments_select_visible
on public.tournaments for select
using (status <> 'draft' or created_by_id = public.current_app_user_id() or public.is_admin());

create policy tournaments_admin_all
on public.tournaments for all
using (public.is_admin())
with check (public.is_admin());

create policy tournament_registrations_select_related
on public.tournament_registrations for select
using (
  user_id = public.current_app_user_id()
  or public.is_admin()
  or exists (
    select 1 from public.tournaments t
    where t.id = tournament_registrations.tournament_id
      and t.status in ('registration_open', 'registration_closed', 'active', 'completed')
  )
);

create policy tournament_registrations_insert_self_open
on public.tournament_registrations for insert
with check (
  user_id = public.current_app_user_id()
  and exists (
    select 1 from public.tournaments t
    where t.id = tournament_registrations.tournament_id
      and t.status = 'registration_open'
  )
);

create policy tournament_registrations_delete_self_open
on public.tournament_registrations for delete
using (
  user_id = public.current_app_user_id()
  and exists (
    select 1 from public.tournaments t
    where t.id = tournament_registrations.tournament_id
      and t.status = 'registration_open'
  )
);

create policy tournament_registrations_admin_all
on public.tournament_registrations for all
using (public.is_admin())
with check (public.is_admin());

create policy tournament_structure_select_visible
on public.tournament_stages for select
using (
  public.is_admin()
  or exists (
    select 1 from public.tournaments t
    where t.id = tournament_stages.tournament_id
      and t.status in ('registration_closed', 'active', 'completed')
  )
);

create policy tournament_groups_select_visible
on public.tournament_groups for select
using (
  public.is_admin()
  or exists (
    select 1 from public.tournaments t
    where t.id = tournament_groups.tournament_id
      and t.status in ('registration_closed', 'active', 'completed')
  )
);

create policy tournament_brackets_select_visible
on public.tournament_brackets for select
using (
  public.is_admin()
  or exists (
    select 1 from public.tournaments t
    where t.id = tournament_brackets.tournament_id
      and t.status in ('registration_closed', 'active', 'completed')
  )
);

create policy tournament_stages_admin_all
on public.tournament_stages for all using (public.is_admin()) with check (public.is_admin());

create policy tournament_groups_admin_all
on public.tournament_groups for all using (public.is_admin()) with check (public.is_admin());

create policy tournament_brackets_admin_all
on public.tournament_brackets for all using (public.is_admin()) with check (public.is_admin());

create policy matches_select_participant_or_visible
on public.matches for select
using (
  white_player_id = public.current_app_user_id()
  or black_player_id = public.current_app_user_id()
  or public.is_admin()
  or status in ('active', 'completed')
);

create policy matches_admin_all
on public.matches for all
using (public.is_admin())
with check (public.is_admin());

create policy games_select_participant_or_live
on public.games for select
using (
  white_player_id = public.current_app_user_id()
  or black_player_id = public.current_app_user_id()
  or public.is_admin()
  or status in ('active', 'completed')
);

create policy games_admin_all
on public.games for all
using (public.is_admin())
with check (public.is_admin());

create policy moves_select_game_visible
on public.moves for select
using (
  public.is_admin()
  or exists (
    select 1 from public.games g
    where g.id = moves.game_id
      and (
        g.white_player_id = public.current_app_user_id()
        or g.black_player_id = public.current_app_user_id()
        or g.status in ('active', 'completed')
      )
  )
);

create policy moves_admin_all
on public.moves for all
using (public.is_admin())
with check (public.is_admin());

create policy game_clocks_select_game_visible
on public.game_clocks for select
using (
  public.is_admin()
  or exists (
    select 1 from public.games g
    where g.id = game_clocks.game_id
      and (
        g.white_player_id = public.current_app_user_id()
        or g.black_player_id = public.current_app_user_id()
        or g.status in ('active', 'completed')
      )
  )
);

create policy game_clocks_admin_all
on public.game_clocks for all
using (public.is_admin())
with check (public.is_admin());

create policy invitations_select_involved
on public.invitations for select
using (
  sender_id = public.current_app_user_id()
  or receiver_id = public.current_app_user_id()
  or public.is_admin()
);

create policy invitations_insert_self
on public.invitations for insert
with check (sender_id = public.current_app_user_id());

create policy invitations_update_involved
on public.invitations for update
using (sender_id = public.current_app_user_id() or receiver_id = public.current_app_user_id() or public.is_admin())
with check (sender_id = public.current_app_user_id() or receiver_id = public.current_app_user_id() or public.is_admin());

create policy spectator_sessions_select_game_visible
on public.spectator_sessions for select
using (
  public.is_admin()
  or exists (
    select 1 from public.games g
    where g.id = spectator_sessions.game_id
      and g.status in ('active', 'completed')
  )
);

create policy spectator_sessions_insert_self_or_anonymous
on public.spectator_sessions for insert
with check (user_id is null or user_id = public.current_app_user_id());

create policy spectator_sessions_update_self
on public.spectator_sessions for update
using (user_id = public.current_app_user_id() or public.is_admin())
with check (user_id = public.current_app_user_id() or public.is_admin());

create policy game_views_insert_self_or_anonymous
on public.game_views for insert
with check (user_id is null or user_id = public.current_app_user_id());

create policy game_views_admin_select
on public.game_views for select
using (public.is_admin());

create policy rankings_select_all
on public.rankings for select
using (true);

create policy rankings_admin_all
on public.rankings for all
using (public.is_admin())
with check (public.is_admin());

create policy competition_rankings_select_all
on public.competition_rankings for select
using (true);

create policy competition_rankings_admin_all
on public.competition_rankings for all
using (public.is_admin())
with check (public.is_admin());

create policy badges_select_active
on public.badges for select
using (is_active = true or public.is_admin());

create policy badges_admin_all
on public.badges for all
using (public.is_admin())
with check (public.is_admin());

create policy user_badges_select_visible
on public.user_badges for select
using (user_id = public.current_app_user_id() or public.is_admin() or true);

create policy user_badges_admin_all
on public.user_badges for all
using (public.is_admin())
with check (public.is_admin());

create policy notifications_select_self
on public.notifications for select
using (user_id = public.current_app_user_id() or public.is_admin());

create policy notifications_update_self_read
on public.notifications for update
using (user_id = public.current_app_user_id() or public.is_admin())
with check (user_id = public.current_app_user_id() or public.is_admin());

create policy notifications_admin_insert
on public.notifications for insert
with check (public.is_admin());

create policy audit_logs_admin_select
on public.audit_logs for select
using (public.is_admin());

create policy disputes_select_involved_or_admin
on public.disputes for select
using (
  opened_by_id = public.current_app_user_id()
  or assigned_admin_id = public.current_app_user_id()
  or public.is_admin()
);

create policy disputes_insert_self
on public.disputes for insert
with check (opened_by_id = public.current_app_user_id());

create policy disputes_admin_update
on public.disputes for update
using (public.is_admin())
with check (public.is_admin());

create policy admin_corrections_admin_select
on public.admin_corrections for select
using (public.is_admin());

create policy admin_corrections_admin_insert
on public.admin_corrections for insert
with check (public.is_admin());
