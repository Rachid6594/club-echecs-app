'use client';

import { useEffect, useState } from 'react';
import { AdminShell } from '../../components/AdminShell';
import { StatusMessage } from '../../components/StatusMessage';
import { ApiState, Badge } from '../../lib/admin-api';
import { adminClientFetch } from '../../lib/admin-client';

export default function BadgesPage() {
  const [state, setState] = useState<ApiState<{ results: Badge[] }> | null>(null);

  useEffect(() => {
    adminClientFetch<{ results: Badge[] }>('/admin/badges/').then(setState);
  }, []);

  return (
    <AdminShell>
      <section className="topbar"><div><p className="eyebrow">Supabase live</p><h2>Badges</h2></div></section>
      <section className="grid">
        {!state ? <StatusMessage title="Chargement" detail="Lecture securisee des badges..." /> : !state.ok ? <StatusMessage title="Connexion admin requise" detail={state.error} /> : (
          state.data.results.length === 0 ? <article className="panel"><p>Aucun badge dans Supabase.</p></article> : state.data.results.map((badge) => (
            <article className="panel" key={badge.id}>
              <h3>{badge.name}</h3>
              <p>{badge.description ?? badge.code}</p>
              <p>{badge.category} | {badge.points_threshold ?? 0} pts</p>
            </article>
          ))
        )}
      </section>
    </AdminShell>
  );
}
