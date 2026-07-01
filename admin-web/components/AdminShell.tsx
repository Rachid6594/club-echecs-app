'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

const navItems = [
  { href: '/', label: 'Dashboard' },
  { href: '/members', label: 'Membres' },
  { href: '/tournaments', label: 'Tournois' },
  { href: '/disputes', label: 'Litiges' },
  { href: '/badges', label: 'Badges' },
  { href: '/audit', label: 'Audit logs' },
];

export function AdminShell({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  useEffect(() => {
    const rawUser = window.localStorage.getItem('club_echecs_user');
    let user: { role?: string } | null = null;
    try {
      user = rawUser ? JSON.parse(rawUser) : null;
    } catch {
      user = null;
    }
    const isAdmin = user?.role === 'admin' || user?.role === 'super_admin';
    if (!isAdmin) {
      window.localStorage.removeItem('club_echecs_access');
      window.localStorage.removeItem('club_echecs_user');
    }
    setIsLoggedIn(Boolean(window.localStorage.getItem('club_echecs_access')) && isAdmin);
  }, []);

  function logout() {
    window.localStorage.removeItem('club_echecs_access');
    window.localStorage.removeItem('club_echecs_user');
    setIsLoggedIn(false);
    router.push('/login');
  }

  return (
    <main className="shell">
      <aside className="sidebar">
        <h1>Club Echecs Admin</h1>
        <nav>
          {navItems.map((item) => (
            <Link key={item.href} href={item.href}>
              {item.label}
            </Link>
          ))}
          {isLoggedIn ? (
            <button className="nav-button" type="button" onClick={logout}>
              Deconnexion
            </button>
          ) : (
            <Link href="/login">Connexion</Link>
          )}
        </nav>
      </aside>
      <section className="content">{children}</section>
    </main>
  );
}
