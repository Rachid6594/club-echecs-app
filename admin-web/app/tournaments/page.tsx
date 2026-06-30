import { AdminShell } from '../../components/AdminShell';
import { StatusMessage } from '../../components/StatusMessage';
import { TournamentForm } from '../../components/TournamentForm';
import { adminFetch, Tournament } from '../../lib/admin-api';

export default async function TournamentsPage() {
  const state = await adminFetch<{ results: Tournament[] }>('/admin/tournaments/');

  return (
    <AdminShell>
      <section className="topbar">
        <div>
          <p className="eyebrow">Supabase live</p>
          <h2>Tournois</h2>
        </div>
      </section>
      <section className="grid">
        <article className="panel">
          <h3>Creation tournoi</h3>
          <TournamentForm />
        </article>
        <article className="panel wide">
          <h3>Tournois en base</h3>
          {!state.ok ? <StatusMessage title="Connexion impossible" detail={state.error} /> : (
            <div className="table">
              <div className="table-row table-head"><span>Nom</span><span>Format</span><span>Status</span><span>Max</span><span>Createur</span></div>
              {state.data.results.length === 0 ? <p>Aucun tournoi dans Supabase.</p> : state.data.results.map((tournament) => (
                <div className="table-row" key={tournament.id}>
                  <span>{tournament.name}</span>
                  <span>{tournament.format}</span>
                  <span>{tournament.status}</span>
                  <span>{tournament.max_players ?? '-'}</span>
                  <span>{tournament.created_by_username ?? '-'}</span>
                </div>
              ))}
            </div>
          )}
        </article>
      </section>
    </AdminShell>
  );
}
