import { adminApiUrl, ApiState } from './admin-api';

export function readAdminToken() {
  if (typeof window === 'undefined') return null;
  return window.localStorage.getItem('club_echecs_access');
}

export function hasAdminSession() {
  if (typeof window === 'undefined') return false;
  const rawUser = window.localStorage.getItem('club_echecs_user');
  try {
    const user = rawUser ? JSON.parse(rawUser) : null;
    return Boolean(readAdminToken()) && (user?.role === 'admin' || user?.role === 'super_admin');
  } catch {
    return false;
  }
}

export async function adminClientFetch<T>(path: string, init?: RequestInit): Promise<ApiState<T>> {
  const token = readAdminToken();
  if (!token) return { ok: false, error: 'Connexion admin requise.' };
  try {
    const response = await fetch(adminApiUrl(path), {
      ...init,
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
        ...(init?.headers ?? {}),
      },
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
