'use client';

import { useEffect, useState } from 'react';
import { AdminShell } from '../../components/AdminShell';
import { MemberForm } from '../../components/MemberForm';
import { StatusMessage } from '../../components/StatusMessage';
import { ApiState, Member } from '../../lib/admin-api';
import { adminClientFetch } from '../../lib/admin-client';

export default function MembersPage() {
  const [state, setState] = useState<ApiState<{ results: Member[] }> | null>(null);

  useEffect(() => {
    adminClientFetch<{ results: Member[] }>('/admin/members/').then(setState);
  }, []);

  return (
    <AdminShell>
      <section className="topbar">
        <div>
          <p className="eyebrow">Supabase live</p>
          <h2>Membres</h2>
        </div>
      </section>
      <section className="grid">
        <article className="panel">
          <h3>Ajouter un membre reel</h3>
          <MemberForm />
        </article>
        <article className="panel wide">
          <h3>Liste des membres</h3>
          {!state ? <StatusMessage title="Chargement" detail="Lecture securisee des membres..." /> : !state.ok ? <StatusMessage title="Connexion admin requise" detail={state.error} /> : (
            <div className="table">
              <div className="table-row table-head"><span>Nom</span><span>Email</span><span>Role</span><span>Rang</span><span>Points</span></div>
              {state.data.results.length === 0 ? <p>Aucun membre dans Supabase.</p> : state.data.results.map((member) => (
                <div className="table-row" key={member.id}>
                  <span>{member.display_name ?? member.username}</span>
                  <span>{member.email}</span>
                  <span>{member.role}</span>
                  <span>{member.rank_name}</span>
                  <span>{member.points}</span>
                </div>
              ))}
            </div>
          )}
        </article>
      </section>
    </AdminShell>
  );
}
