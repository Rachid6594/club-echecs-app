import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';

const page = readFileSync(new URL('../app/page.tsx', import.meta.url), 'utf8');

for (const text of [
  'Login admin',
  'Dashboard general',
  'Gestion des membres',
  'Creation tournoi',
  'Tirage aleatoire',
  'Tableau visuel elimination directe',
  'Litiges et corrections',
  'Gestion badges/rangs',
  'Audit logs',
]) {
  assert.ok(page.includes(text), `Missing admin text: ${text}`);
}

console.log('Admin static content OK');

