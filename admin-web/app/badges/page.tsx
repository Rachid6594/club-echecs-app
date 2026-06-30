import { AdminShell } from '../../components/AdminShell';
import { StatusMessage } from '../../components/StatusMessage';
import { adminFetch, Badge } from '../../lib/admin-api';

export default async function BadgesPage() {
  const state = await adminFetch<{ results: Badge[] }>('/admin/badges/');

  return (
    <AdminShell>
      <section className="topbar"><div><p className="eyebrow">Supabase live</p><h2>Badges</h2></div></section>
      <section className="grid">
        {!state.ok ? <StatusMessage title="Connexion impossible" detail={state.error} /> : (
          state.data.results.length === 0 ? <article className="panel"><p>Aucun badge dans Supabase.</p></article> : state.data.results.map((badge) => (
            <article className="panel" key={badge.id}>
              <h3>{badge.name}</h3>
              <p>{badge.description ?? badge.code}</p>
              <p>{badge.category} · {badge.points_threshold ?? 0} pts</p>
            </article>
          ))
        )}
      </section>
    </AdminShell>
  );
}
