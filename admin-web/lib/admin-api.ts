export type ApiState<T> =
  | { ok: true; data: T }
  | { ok: false; error: string };

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL ?? 'https://club-echecs-api.vercel.app/api';

export async function adminFetch<T>(path: string, init?: RequestInit): Promise<ApiState<T>> {
  try {
    const response = await fetch(`${API_BASE_URL}${path}`, {
      ...init,
      headers: {
        'Content-Type': 'application/json',
        ...(init?.headers ?? {}),
      },
      cache: 'no-store',
    });
    const payload = await response.json().catch(() => ({}));
    if (!response.ok) {
      return { ok: false, error: payload.detail ?? `Erreur API ${response.status}` };
    }
    return { ok: true, data: payload as T };
  } catch (error) {
    return { ok: false, error: error instanceof Error ? error.message : 'API indisponible' };
  }
}

export function adminApiUrl(path: string) {
  return `${API_BASE_URL}${path}`;
}

export type DashboardPayload = {
  metrics: {
    active_members: number;
    open_matches: number;
    open_tournaments: number;
    open_disputes: number;
    active_badges: number;
  };
  members: Member[];
  tournaments: Tournament[];
  disputes: Dispute[];
  audit_logs: AuditLog[];
};

export type Member = {
  id: string;
  member_number: string | null;
  status: string;
  joined_at: string | null;
  user_id?: string;
  username: string;
  email: string;
  role?: string;
  display_name: string | null;
  country_code?: string | null;
  points: number;
  wins?: number;
  draws?: number;
  losses?: number;
  games_played?: number;
  rank_name: string;
};

export type Tournament = {
  id: string;
  name: string;
  description?: string | null;
  format: string;
  status: string;
  starts_at: string | null;
  ends_at?: string | null;
  max_players: number | null;
  time_control_initial_seconds?: number;
  time_control_increment_seconds?: number;
  created_at: string;
  created_by_username?: string | null;
};

export type Dispute = {
  id: string;
  status: string;
  reason: string;
  resolution: string | null;
  created_at: string;
  resolved_at: string | null;
  opened_by_username?: string;
  assigned_admin_username?: string | null;
};

export type Badge = {
  id: string;
  code: string;
  name: string;
  description: string | null;
  category: string;
  icon_path: string;
  points_threshold: number | null;
  sort_order: number;
  is_active: boolean;
};

export type AuditLog = {
  id: string;
  action: string;
  entity_type: string;
  entity_id: string | null;
  metadata: Record<string, unknown>;
  created_at: string;
  actor_username?: string | null;
};
