import { readdirSync, readFileSync } from 'node:fs';
import assert from 'node:assert/strict';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

function readTsxFiles(dir) {
  return readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) return readTsxFiles(path);
    return entry.name.endsWith('.tsx') ? [readFileSync(path, 'utf8')] : [];
  });
}

const appDir = fileURLToPath(new URL('../app', import.meta.url));
const componentDir = fileURLToPath(new URL('../components', import.meta.url));
const page = [...readTsxFiles(appDir), ...readTsxFiles(componentDir)].join('\n');

for (const text of [
  'Supabase live',
  'Dashboard general',
  'Membres',
  'Creation tournoi',
  'Litiges et corrections',
  'Badges',
  'Audit logs',
  'Connexion admin',
  'Creer un compte',
  '/admin/dashboard/',
  '/admin/members/',
  '/admin/tournaments/',
  '/app/auth/login/',
  '/app/auth/register/',
]) {
  assert.ok(page.includes(text), `Missing admin text: ${text}`);
}

console.log('Admin static content OK');

