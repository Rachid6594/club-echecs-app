import { AdminShell } from '../../components/AdminShell';
import { StatusMessage } from '../../components/StatusMessage';
import { adminFetch, AuditLog } from '../../lib/admin-api';

export default async function AuditPage() {
  const state = await adminFetch<{ results: AuditLog[] }>('/admin/audit-logs/');

  return (
    <AdminShell>
      <section className="topbar"><div><p className="eyebrow">Supabase live</p><h2>Audit logs</h2></div></section>
      <article className="panel wide">
        {!state.ok ? <StatusMessage title="Connexion impossible" detail={state.error} /> : (
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
