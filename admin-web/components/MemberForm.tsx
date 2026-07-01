'use client';

import { useState } from 'react';
import { adminApiUrl } from '../lib/admin-api';
import { readAdminToken } from '../lib/admin-client';

export function MemberForm() {
  const [message, setMessage] = useState('');
  const [pending, setPending] = useState(false);

  async function submit(formData: FormData) {
    setPending(true);
    setMessage('');
    const response = await fetch(adminApiUrl('/admin/members/'), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${readAdminToken() ?? ''}` },
      body: JSON.stringify(Object.fromEntries(formData)),
    });
    const payload = await response.json().catch(() => ({}));
    setPending(false);
    if (!response.ok) {
      setMessage(payload.detail ?? 'Creation impossible');
      return;
    }
    setMessage('Membre cree dans Supabase.');
    window.location.reload();
  }

  return (
    <form action={submit} className="form-panel">
      <label>Nom utilisateur<input name="username" required placeholder="rachid" /></label>
      <label>Email<input name="email" type="email" required placeholder="rachid@club.test" /></label>
      <label>Mot de passe<input name="password" type="password" required minLength={8} placeholder="Minimum 8 caracteres" /></label>
      <label>Nom affiche<input name="display_name" placeholder="Rachid" /></label>
      <label>Numero membre<input name="member_number" placeholder="CE-001" /></label>
      <label>Role<select name="role" defaultValue="player"><option value="player">Joueur</option><option value="admin">Admin</option><option value="super_admin">Super admin</option></select></label>
      <button type="submit" disabled={pending}>{pending ? 'Creation...' : 'Creer membre'}</button>
      {message ? <p className="form-message">{message}</p> : null}
    </form>
  );
}
