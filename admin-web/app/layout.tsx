import './globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Club Echecs Admin',
  description: 'Dashboard admin du club echecs',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="fr">
      <body>{children}</body>
    </html>
  );
}

