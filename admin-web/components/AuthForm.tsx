'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { adminApiUrl } from '../lib/admin-api';

type Mode = 'login' | 'register';

export function AuthForm({ mode }: { mode: Mode }) {
  const router = useRouter();
  const [message, setMessage] = useState('');
  const [pending, setPending] = useState(false);

  async function submit(formData: FormData) {
    setPending(true);
    setMessage('');
    const endpoint = mode === 'login' ? '/admin/auth/login/' : '/admin/auth/register/';
    const response = await fetch(adminApiUrl(endpoint), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(Object.fromEntries(formData)),
    });
    const payload = await response.json().catch(() => ({}));
    setPending(false);
    if (!response.ok) {
      setMessage(payload.detail ?? 'Action impossible');
      return;
    }
    window.localStorage.setItem('club_echecs_user', JSON.stringify(payload.user));
    window.localStorage.setItem('club_echecs_access', payload.tokens?.access ?? '');
    router.push('/');
  }

  return (
    <form action={submit} className="auth-card">
      <h1>{mode === 'login' ? 'Connexion admin' : 'Creer un compte admin'}</h1>
      {mode === 'register' ? (
        <>
          <label>Nom utilisateur<input name="username" required minLength={3} /></label>
          <label>Nom affiche<input name="display_name" /></label>
          <label>Role<select name="role" defaultValue="admin"><option value="admin">Admin</option><option value="super_admin">Super admin</option></select></label>
        </>
      ) : null}
      <label>Email<input name="email" type="email" required /></label>
      <label>Mot de passe<input name="password" type="password" required minLength={8} /></label>
      <button type="submit" disabled={pending}>{pending ? 'Patiente...' : mode === 'login' ? 'Se connecter' : 'Creer le compte'}</button>
      {message ? <p className="form-message">{message}</p> : null}
      {mode === 'login' ? (
        <Link href="/register">Creer un compte</Link>
      ) : (
        <Link href="/login">J ai deja un compte</Link>
      )}
    </form>
  );
}
