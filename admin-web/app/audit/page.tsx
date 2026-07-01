'use client';

import { useEffect, useState } from 'react';
import { AdminShell } from '../../components/AdminShell';
import { StatusMessage } from '../../components/StatusMessage';
import { ApiState, AuditLog } from '../../lib/admin-api';
import { adminClientFetch } from '../../lib/admin-client';

export default function AuditPage() {
  const [state, setState] = useState<ApiState<{ results: AuditLog[] }> | null>(null);

  useEffect(() => {
    adminClientFetch<{ results: AuditLog[] }>('/admin/audit-logs/').then(setState);
  }, []);

  return (
    <AdminShell>
      <section className="topbar"><div><p className="eyebrow">Supabase live</p><h2>Audit logs</h2></div></section>
      <article className="panel wide">
        {!state ? <StatusMessage title="Chargement" detail="Lecture securisee des logs..." /> : !state.ok ? <StatusMessage title="Connexion admin requise" detail={state.error} /> : (
          <div className="table">
            <div className="table-row table-head"><span>Action</span><span>Entite</span><span>Acteur</span><span>Date</span></div>
            {state.data.results.length === 0 ? <p>Aucun audit log dans Supabase.</p> : state.data.results.map((log) => (
              <div className="table-row" key={log.id}>
                <span>{log.action}</span>
                <span>{log.entity_type}</span>
                <span>{log.actor_username ?? 'system'}</span>
                <span>{new Date(log.created_at).toLocaleString('fr-FR')}</span>
              </div>
            ))}
          </div>
        )}
      </article>
    </AdminShell>
  );
}
