# Supabase

Schema PostgreSQL, migrations, policies RLS, fonctions et configuration Realtime.

## Sprint 01

Le socle de donnees est defini dans :

- `migrations/0001_core_schema.sql`
- `policies/0001_initial_rls.sql`

## Ordre d'application local

```bash
supabase db reset
```

Ou, manuellement :

```bash
psql "$DATABASE_URL" -f supabase/migrations/0001_core_schema.sql
psql "$DATABASE_URL" -f supabase/policies/0001_initial_rls.sql
```

## Source de verite

Django reste responsable de la validation finale des coups, scores, corrections admin et regles metier. Supabase stocke l'etat, applique les protections RLS pour l'acces direct et diffuse les evenements Realtime.
