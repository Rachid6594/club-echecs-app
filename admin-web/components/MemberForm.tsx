'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { adminApiUrl } from '../lib/admin-api';

export function MemberForm() {
  const router = useRouter();
  const [message, setMessage] = useState('');
  const [pending, setPending] = useState(false);

  async function submit(formData: FormData) {
    setPending(true);
    setMessage('');
    const response = await fetch(adminApiUrl('/admin/members/'), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(Object.fromEntries(formData)),
    });
    const payload = await response.json().catch(() => ({}));
    setPending(false);
    if (!response.ok) {
      setMessage(payload.detail ?? 'Creation impossible');
      return;
    }
    setMessage('Membre cree dans Supabase.');
    router.refresh();
  }

  return (
    <form action={submit} className="form-panel">
      <label>Nom utilisateur<input name="username" required placeholder="rachid" /></label>
      <label>Email<input name="email" type="email" required placeholder="rachid@club.test" /></label>
      <label>Nom affiche<input name="display_name" placeholder="Rachid" /></label>
      <label>Numero membre<input name="member_number" placeholder="CE-001" /></label>
      <label>Role<select name="role" defaultValue="player"><option value="player">Joueur</option><option value="admin">Admin</option><option value="super_admin">Super admin</option></select></label>
      <button type="submit" disabled={pending}>{pending ? 'Creation...' : 'Creer membre'}</button>
      {message ? <p className="form-message">{message}</p> : null}
    </form>
  );
}
