import Link from 'next/link';

const navItems = [
  { href: '/', label: 'Dashboard' },
  { href: '/members', label: 'Membres' },
  { href: '/tournaments', label: 'Tournois' },
  { href: '/disputes', label: 'Litiges' },
  { href: '/badges', label: 'Badges' },
  { href: '/audit', label: 'Audit logs' },
  { href: '/login', label: 'Connexion' },
];

export function AdminShell({ children }: { children: React.ReactNode }) {
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
        </nav>
      </aside>
      <section className="content">{children}</section>
    </main>
  );
}
