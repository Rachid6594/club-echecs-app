import Link from 'next/link';
import { AdminShell } from '../components/AdminShell';
import { StatusMessage } from '../components/StatusMessage';
import { adminFetch, DashboardPayload } from '../lib/admin-api';

export default async function AdminDashboard() {
  const state = await adminFetch<DashboardPayload>('/admin/dashboard/');

  return (
    <AdminShell>
      <section className="topbar">
        <div>
          <p className="eyebrow">Supabase live</p>
          <h2>Dashboard general</h2>
        </div>
        <Link className="button" href="/tournaments">Nouvelle competition</Link>
      </section>

      {!state.ok ? (
        <StatusMessage title="Connexion Supabase requise" detail={state.error} />
      ) : (
        <>
          <section className="metrics">
            <article><span>Membres actifs</span><strong>{state.data.metrics.active_members}</strong></article>
            <article><span>Matchs ouverts</span><strong>{state.data.metrics.open_matches}</strong></article>
            <article><span>Tournois ouverts</span><strong>{state.data.metrics.open_tournaments}</strong></article>
            <article><span>Litiges ouverts</span><strong>{state.data.metrics.open_disputes}</strong></article>
          </section>

          <section className="grid">
            <article className="panel">
              <h3>Derniers membres</h3>
              {state.data.members.length === 0 ? <p>Aucun membre dans Supabase.</p> : state.data.members.map((member) => (
                <p key={member.id}>{member.display_name ?? member.username} · {member.rank_name} · {member.points} pts</p>
              ))}
              <Link href="/members">Gerer les membres</Link>
            </article>

            <article className="panel">
              <h3>Tournois</h3>
              {state.data.tournaments.length === 0 ? <p>Aucun tournoi dans Supabase.</p> : state.data.tournaments.map((tournament) => (
                <p key={tournament.id}>{tournament.name} · {tournament.status}</p>
              ))}
              <Link href="/tournaments">Gerer les tournois</Link>
            </article>

            <article className="panel">
              <h3>Litiges</h3>
              {state.data.disputes.length === 0 ? <p>Aucun litige dans Supabase.</p> : state.data.disputes.map((dispute) => (
                <p key={dispute.id}>{dispute.reason} · {dispute.status}</p>
              ))}
              <Link href="/disputes">Voir les litiges</Link>
            </article>

            <article className="panel">
              <h3>Audit logs</h3>
              {state.data.audit_logs.length === 0 ? <p>Aucun audit log dans Supabase.</p> : state.data.audit_logs.map((log) => (
                <p key={log.id}>{log.action} · {log.entity_type}</p>
              ))}
              <Link href="/audit">Voir les logs</Link>
            </article>
          </section>
        </>
      )}
    </AdminShell>
  );
}
