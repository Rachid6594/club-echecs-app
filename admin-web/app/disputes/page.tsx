'use client';

import { useEffect, useState } from 'react';
import { AdminShell } from '../../components/AdminShell';
import { StatusMessage } from '../../components/StatusMessage';
import { ApiState, Dispute } from '../../lib/admin-api';
import { adminClientFetch } from '../../lib/admin-client';

export default function DisputesPage() {
  const [state, setState] = useState<ApiState<{ results: Dispute[] }> | null>(null);

  useEffect(() => {
    adminClientFetch<{ results: Dispute[] }>('/admin/disputes/').then(setState);
  }, []);

  return (
    <AdminShell>
      <section className="topbar"><div><p className="eyebrow">Supabase live</p><h2>Litiges</h2></div></section>
      <article className="panel wide">
        <h3>Litiges et corrections</h3>
        {!state ? <StatusMessage title="Chargement" detail="Lecture securisee des litiges..." /> : !state.ok ? <StatusMessage title="Connexion admin requise" detail={state.error} /> : (
          <div className="table">
            <div className="table-row table-head"><span>Raison</span><span>Status</span><span>Ouvert par</span><span>Resolution</span></div>
            {state.data.results.length === 0 ? <p>Aucun litige dans Supabase.</p> : state.data.results.map((dispute) => (
              <div className="table-row" key={dispute.id}>
                <span>{dispute.reason}</span>
                <span>{dispute.status}</span>
                <span>{dispute.opened_by_username ?? '-'}</span>
                <span>{dispute.resolution ?? '-'}</span>
              </div>
            ))}
          </div>
        )}
      </article>
    </AdminShell>
  );
}
