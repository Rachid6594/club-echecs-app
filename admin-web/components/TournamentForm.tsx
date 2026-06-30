'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { adminApiUrl } from '../lib/admin-api';

export function TournamentForm() {
  const router = useRouter();
  const [message, setMessage] = useState('');
  const [pending, setPending] = useState(false);

  async function submit(formData: FormData) {
    setPending(true);
    setMessage('');
    const values = Object.fromEntries(formData);
    const response = await fetch(adminApiUrl('/admin/tournaments/'), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(values),
    });
    const payload = await response.json().catch(() => ({}));
    setPending(false);
    if (!response.ok) {
      setMessage(payload.detail ?? 'Creation impossible');
      return;
    }
    setMessage('Tournoi cree dans Supabase.');
    router.refresh();
  }

  return (
    <form action={submit} className="form-panel">
      <label>Nom du tournoi<input name="name" required placeholder="Coupe du Club" /></label>
      <label>Description<input name="description" placeholder="Tournoi mensuel" /></label>
      <label>Format<select name="format" defaultValue="single_elimination"><option value="single_elimination">Elimination directe</option><option value="round_robin">Round-robin</option><option value="groups_then_knockout">Groupes + finale</option></select></label>
      <label>Joueurs max<input name="max_players" type="number" min="2" placeholder="16" /></label>
      <button type="submit" disabled={pending}>{pending ? 'Creation...' : 'Creer tournoi'}</button>
      {message ? <p className="form-message">{message}</p> : null}
    </form>
  );
}
