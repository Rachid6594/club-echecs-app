-- Sprint 01 - Core Supabase PostgreSQL schema for Club Echecs App.
-- Backend Django remains the source of truth for business validation.

create extension if not exists "pgcrypto";

create type public.user_role as enum ('player', 'admin', 'super_admin');
create type public.member_status as enum ('pending', 'active', 'suspended', 'left');
create type public.invitation_status as enum ('pending', 'accepted', 'rejected', 'cancelled', 'expired');
create type public.game_status as enum ('pending', 'active', 'paused', 'completed', 'cancelled', 'disputed');
create type public.game_result as enum ('white_win', 'black_win', 'draw', 'abandoned', 'timeout', 'admin_corrected');
create type public.match_status as enum ('scheduled', 'active', 'completed', 'cancelled', 'disputed');
create type public.tournament_format as enum ('single_elimination', 'round_robin', 'groups_then_knockout');
create type public.tournament_status as enum ('draft', 'registration_open', 'registration_closed', 'active', 'completed', 'cancelled');
create type public.stage_type as enum ('group', 'knockout', 'round_robin', 'final');
create type public.color_side as enum ('white', 'black');
create type public.notification_type as enum ('invitation', 'match_reminder', 'tournament', 'result', 'badge', 'system');
create type public.dispute_status as enum ('open', 'under_review', 'resolved', 'rejected');
create type public.badge_category as enum ('rank', 'achievement', 'competition', 'activity');

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table public.app_users (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid unique,
  email text not null unique,
  username text not null unique,
  role public.user_role not null default 'player',
  is_active boolean not null default true,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint app_users_email_format_chk check (position('@' in email) > 1),
  constraint app_users_username_length_chk check (char_length(username) between 3 and 32)
);

create trigger app_users_set_updated_at
before update on public.app_users
for each row execute function public.set_updated_at();

create table public.user_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.app_users(id) on delete cascade,
  display_name text not null,
  avatar_url text,
  bio text,
  country_code char(2),
  fide_id text,
  club_joined_at date,
  total_points integer not null default 0,
  total_wins integer not null default 0,
  total_draws integer not null default 0,
  total_losses integer not null default 0,
  current_streak integer not null default 0,
  best_streak integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_profiles_points_chk check (total_points >= 0),
  constraint user_profiles_stats_chk check (
    total_wins >= 0 and total_draws >= 0 and total_losses >= 0 and
    current_streak >= 0 and best_streak >= 0
  )
);

create trigger user_profiles_set_updated_at
before update on public.user_profiles
for each row execute function public.set_updated_at();

create table public.club_members (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.app_users(id) on delete cascade,
  member_number text unique,
  status public.member_status not null default 'pending',
  joined_at timestamptz,
  suspended_at timestamptz,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger club_members_set_updated_at
before update on public.club_members
for each row execute function public.set_updated_at();

create table public.tournaments (
  id uuid primary key default gen_random_uuid(),
  created_by_id uuid not null references public.app_users(id) on delete restrict,
  name text not null,
  description text,
  format public.tournament_format not null,
  status public.tournament_status not null default 'draft',
  starts_at timestamptz,
  ends_at timestamptz,
  registration_opens_at timestamptz,
  registration_closes_at timestamptz,
  max_players integer,
  time_control_initial_seconds integer not null default 600,
  time_control_increment_seconds integer not null default 0,
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint tournaments_name_length_chk check (char_length(name) between 3 and 120),
  constraint tournaments_max_players_chk check (max_players is null or max_players >= 2),
  constraint tournaments_time_control_chk check (
    time_control_initial_seconds > 0 and time_control_increment_seconds >= 0
  ),
  constraint tournaments_dates_chk check (
    ends_at is null or starts_at is null or ends_at >= starts_at
  )
);

create trigger tournaments_set_updated_at
before update on public.tournaments
for each row execute function public.set_updated_at();

create table public.tournament_registrations (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  user_id uuid not null references public.app_users(id) on delete cascade,
  seed integer,
  checked_in_at timestamptz,
  created_at timestamptz not null default now(),
  unique (tournament_id, user_id),
  unique (tournament_id, seed),
  constraint tournament_registrations_seed_chk check (seed is null or seed > 0)
);

create table public.tournament_stages (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  name text not null,
  stage_type public.stage_type not null,
  position integer not null,
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tournament_id, position),
  constraint tournament_stages_position_chk check (position > 0)
);

create trigger tournament_stages_set_updated_at
before update on public.tournament_stages
for each row execute function public.set_updated_at();

create table public.tournament_groups (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  stage_id uuid references public.tournament_stages(id) on delete cascade,
  name text not null,
  position integer not null,
  created_at timestamptz not null default now(),
  unique (tournament_id, name),
  unique (tournament_id, position),
  constraint tournament_groups_position_chk check (position > 0)
);

create table public.tournament_brackets (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  stage_id uuid references public.tournament_stages(id) on delete cascade,
  round_number integer not null,
  match_number integer not null,
  slot_number integer not null,
  source_match_id uuid,
  player_id uuid references public.app_users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tournament_id, round_number, match_number, slot_number),
  constraint tournament_brackets_round_chk check (round_number > 0),
  constraint tournament_brackets_match_chk check (match_number > 0),
  constraint tournament_brackets_slot_chk check (slot_number in (1, 2))
);

create trigger tournament_brackets_set_updated_at
before update on public.tournament_brackets
for each row execute function public.set_updated_at();

create table public.matches (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid references public.tournaments(id) on delete cascade,
  stage_id uuid references public.tournament_stages(id) on delete set null,
  group_id uuid references public.tournament_groups(id) on delete set null,
  bracket_id uuid references public.tournament_brackets(id) on delete set null,
  white_player_id uuid references public.app_users(id) on delete restrict,
  black_player_id uuid references public.app_users(id) on delete restrict,
  winner_id uuid references public.app_users(id) on delete set null,
  status public.match_status not null default 'scheduled',
  scheduled_at timestamptz,
  completed_at timestamptz,
  white_score numeric(4,2) not null default 0,
  black_score numeric(4,2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint matches_distinct_players_chk check (
    white_player_id is null or black_player_id is null or white_player_id <> black_player_id
  ),
  constraint matches_score_chk check (
    white_score in (0, 0.5, 1, 3) and black_score in (0, 0.5, 1, 3)
  )
);

create trigger matches_set_updated_at
before update on public.matches
for each row execute function public.set_updated_at();

alter table public.tournament_brackets
  add constraint tournament_brackets_source_match_fk
  foreign key (source_match_id) references public.matches(id) deferrable initially deferred;

create table public.games (
  id uuid primary key default gen_random_uuid(),
  match_id uuid references public.matches(id) on delete set null,
  white_player_id uuid not null references public.app_users(id) on delete restrict,
  black_player_id uuid not null references public.app_users(id) on delete restrict,
  status public.game_status not null default 'pending',
  result public.game_result,
  winner_id uuid references public.app_users(id) on delete set null,
  initial_fen text not null default 'startpos',
  current_fen text not null default 'startpos',
  pgn text,
  turn public.color_side not null default 'white',
  started_at timestamptz,
  completed_at timestamptz,
  last_move_at timestamptz,
  draw_offered_by_id uuid references public.app_users(id) on delete set null,
  draw_offered_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint games_distinct_players_chk check (white_player_id <> black_player_id),
  constraint games_winner_is_player_chk check (
    winner_id is null or winner_id in (white_player_id, black_player_id)
  ),
  constraint games_draw_offer_is_player_chk check (
    draw_offered_by_id is null or draw_offered_by_id in (white_player_id, black_player_id)
  )
);

create trigger games_set_updated_at
before update on public.games
for each row execute function public.set_updated_at();

create table public.moves (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references public.games(id) on delete cascade,
  player_id uuid not null references public.app_users(id) on delete restrict,
  move_number integer not null,
  side public.color_side not null,
  uci text not null,
  san text,
  fen_before text not null,
  fen_after text not null,
  is_check boolean not null default false,
  is_checkmate boolean not null default false,
  is_castling boolean not null default false,
  is_en_passant boolean not null default false,
  promotion_piece text,
  elapsed_ms integer,
  created_at timestamptz not null default now(),
  unique (game_id, move_number, side),
  constraint moves_move_number_chk check (move_number > 0),
  constraint moves_uci_length_chk check (char_length(uci) between 4 and 5),
  constraint moves_elapsed_chk check (elapsed_ms is null or elapsed_ms >= 0),
  constraint moves_promotion_piece_chk check (
    promotion_piece is null or promotion_piece in ('q', 'r', 'b', 'n')
  )
);

create table public.game_clocks (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null unique references public.games(id) on delete cascade,
  initial_seconds integer not null,
  increment_seconds integer not null default 0,
  white_remaining_ms integer not null,
  black_remaining_ms integer not null,
  active_side public.color_side,
  last_tick_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint game_clocks_time_chk check (
    initial_seconds > 0 and increment_seconds >= 0 and
    white_remaining_ms >= 0 and black_remaining_ms >= 0
  )
);

create trigger game_clocks_set_updated_at
before update on public.game_clocks
for each row execute function public.set_updated_at();

create table public.invitations (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.app_users(id) on delete cascade,
  receiver_id uuid not null references public.app_users(id) on delete cascade,
  status public.invitation_status not null default 'pending',
  proposed_initial_seconds integer not null default 600,
  proposed_increment_seconds integer not null default 0,
  message text,
  expires_at timestamptz not null,
  responded_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint invitations_distinct_users_chk check (sender_id <> receiver_id),
  constraint invitations_time_control_chk check (
    proposed_initial_seconds > 0 and proposed_increment_seconds >= 0
  )
);

create unique index invitations_one_pending_pair_idx
on public.invitations (sender_id, receiver_id)
where status = 'pending';

create trigger invitations_set_updated_at
before update on public.invitations
for each row execute function public.set_updated_at();

create table public.spectator_sessions (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references public.games(id) on delete cascade,
  user_id uuid references public.app_users(id) on delete set null,
  anonymous_id text,
  connected_at timestamptz not null default now(),
  disconnected_at timestamptz,
  last_seen_at timestamptz not null default now(),
  constraint spectator_sessions_identity_chk check (user_id is not null or anonymous_id is not null)
);

create table public.game_views (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references public.games(id) on delete cascade,
  user_id uuid references public.app_users(id) on delete set null,
  anonymous_id text,
  viewed_at timestamptz not null default now(),
  constraint game_views_identity_chk check (user_id is not null or anonymous_id is not null)
);

create table public.rankings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.app_users(id) on delete cascade,
  points integer not null default 0,
  wins integer not null default 0,
  draws integer not null default 0,
  losses integer not null default 0,
  games_played integer not null default 0,
  rank_position integer,
  rank_name text not null default 'Novice I',
  recomputed_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint rankings_non_negative_chk check (
    points >= 0 and wins >= 0 and draws >= 0 and losses >= 0 and games_played >= 0
  ),
  constraint rankings_games_consistency_chk check (games_played = wins + draws + losses)
);

create trigger rankings_set_updated_at
before update on public.rankings
for each row execute function public.set_updated_at();

create table public.competition_rankings (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  user_id uuid not null references public.app_users(id) on delete cascade,
  points integer not null default 0,
  wins integer not null default 0,
  draws integer not null default 0,
  losses integer not null default 0,
  games_played integer not null default 0,
  tie_break_score numeric(8,2) not null default 0,
  rank_position integer,
  recomputed_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tournament_id, user_id),
  constraint competition_rankings_non_negative_chk check (
    points >= 0 and wins >= 0 and draws >= 0 and losses >= 0 and games_played >= 0
  ),
  constraint competition_rankings_games_consistency_chk check (games_played = wins + draws + losses)
);

create trigger competition_rankings_set_updated_at
before update on public.competition_rankings
for each row execute function public.set_updated_at();

create table public.badges (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text,
  category public.badge_category not null,
  icon_path text not null,
  points_threshold integer,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint badges_code_format_chk check (code ~ '^[a-z0-9_]+$'),
  constraint badges_points_threshold_chk check (points_threshold is null or points_threshold >= 0)
);

create trigger badges_set_updated_at
before update on public.badges
for each row execute function public.set_updated_at();

create table public.user_badges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.app_users(id) on delete cascade,
  badge_id uuid not null references public.badges(id) on delete cascade,
  awarded_at timestamptz not null default now(),
  awarded_by_id uuid references public.app_users(id) on delete set null,
  context jsonb not null default '{}'::jsonb,
  unique (user_id, badge_id)
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.app_users(id) on delete cascade,
  type public.notification_type not null,
  title text not null,
  body text not null,
  payload jsonb not null default '{}'::jsonb,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.app_users(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz not null default now(),
  constraint audit_logs_action_length_chk check (char_length(action) between 3 and 120)
);

create table public.disputes (
  id uuid primary key default gen_random_uuid(),
  game_id uuid references public.games(id) on delete cascade,
  match_id uuid references public.matches(id) on delete cascade,
  opened_by_id uuid not null references public.app_users(id) on delete restrict,
  assigned_admin_id uuid references public.app_users(id) on delete set null,
  status public.dispute_status not null default 'open',
  reason text not null,
  resolution text,
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint disputes_target_chk check (game_id is not null or match_id is not null)
);

create trigger disputes_set_updated_at
before update on public.disputes
for each row execute function public.set_updated_at();

create table public.admin_corrections (
  id uuid primary key default gen_random_uuid(),
  dispute_id uuid references public.disputes(id) on delete set null,
  admin_id uuid not null references public.app_users(id) on delete restrict,
  game_id uuid references public.games(id) on delete set null,
  match_id uuid references public.matches(id) on delete set null,
  previous_state jsonb not null,
  corrected_state jsonb not null,
  reason text not null,
  created_at timestamptz not null default now(),
  constraint admin_corrections_target_chk check (game_id is not null or match_id is not null)
);

create index app_users_auth_user_id_idx on public.app_users (auth_user_id);
create index app_users_role_idx on public.app_users (role);
create index club_members_status_idx on public.club_members (status);
create index tournaments_status_format_idx on public.tournaments (status, format);
create index tournament_registrations_tournament_idx on public.tournament_registrations (tournament_id);
create index tournament_stages_tournament_idx on public.tournament_stages (tournament_id, position);
create index tournament_groups_tournament_idx on public.tournament_groups (tournament_id, position);
create index tournament_brackets_tournament_round_idx on public.tournament_brackets (tournament_id, round_number, match_number);
create index matches_tournament_status_idx on public.matches (tournament_id, status);
create index matches_players_idx on public.matches (white_player_id, black_player_id);
create index games_status_idx on public.games (status);
create index games_players_idx on public.games (white_player_id, black_player_id);
create index moves_game_number_idx on public.moves (game_id, move_number);
create index invitations_receiver_status_idx on public.invitations (receiver_id, status);
create index invitations_sender_status_idx on public.invitations (sender_id, status);
create index spectator_sessions_game_live_idx on public.spectator_sessions (game_id) where disconnected_at is null;
create index game_views_game_idx on public.game_views (game_id);
create index rankings_points_idx on public.rankings (points desc, wins desc);
create index competition_rankings_tournament_points_idx on public.competition_rankings (tournament_id, points desc, wins desc, tie_break_score desc);
create index notifications_user_unread_idx on public.notifications (user_id, created_at desc) where read_at is null;
create index audit_logs_entity_idx on public.audit_logs (entity_type, entity_id);
create index disputes_status_idx on public.disputes (status);

alter publication supabase_realtime add table
  public.games,
  public.moves,
  public.game_clocks,
  public.invitations,
  public.spectator_sessions,
  public.notifications,
  public.tournament_brackets,
  public.matches;
