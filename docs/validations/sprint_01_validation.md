# Sprint 01 - Base de donnees Supabase

## Resume du sprint

Le schema PostgreSQL Supabase initial a ete cree avec les entites principales du produit, les relations, les contraintes, les index, les policies RLS initiales et les tables Realtime.

## Fonctionnalites realisees

- Creation de la migration `0001_core_schema.sql`.
- Creation des enums metier : roles, statuts, formats tournoi, resultats, notifications, litiges, badges.
- Creation des tables minimales demandees :
  - `app_users`
  - `user_profiles`
  - `club_members`
  - `tournaments`
  - `tournament_registrations`
  - `tournament_stages`
  - `tournament_groups`
  - `tournament_brackets`
  - `matches`
  - `games`
  - `moves`
  - `game_clocks`
  - `invitations`
  - `spectator_sessions`
  - `game_views`
  - `rankings`
  - `competition_rankings`
  - `badges`
  - `user_badges`
  - `notifications`
  - `audit_logs`
  - `disputes`
  - `admin_corrections`
- Creation des relations et contraintes d'integrite.
- Creation des index principaux.
- Activation des tables Realtime necessaires aux parties, invitations, notifications, spectateurs et brackets.
- Creation des policies RLS initiales dans `0001_initial_rls.sql`.
- Documentation du modele de donnees.
- Documentation initiale RLS/securite.
- Mise a jour du README Supabase.

## Fichiers crees/modifies

- `supabase/migrations/0001_core_schema.sql`
- `supabase/policies/0001_initial_rls.sql`
- `supabase/README.md`
- `docs/architecture/data_model.md`
- `docs/security/rls.md`
- `docs/validations/sprint_01_validation.md`

## Tests executes

- Verification de presence des fichiers Sprint 01.
- Verification que toutes les tables minimales demandees sont presentes dans la migration.
- Verification que les tables principales ont RLS active dans le fichier de policies.
- Verification que les tables Realtime demandees sont ajoutees a `supabase_realtime`.
- Parsing PostgreSQL local avec `pglast` des fichiers SQL.
- Scan local de secrets evidents.
- Verification Git de la branche de sprint.

## Resultats des tests

- Fichiers Sprint 01 : OK.
- Tables minimales : OK.
- RLS initiales : OK.
- Realtime : OK.
- Parsing PostgreSQL : OK, `0001_core_schema.sql` parse avec 77 statements et `0001_initial_rls.sql` avec 75 statements.
- Secrets evidents : OK.
- Test d'application runtime PostgreSQL/Supabase : non execute, car `psql` et `supabase` ne sont pas installes et le daemon Docker Desktop n'est pas demarre.

## Bugs detectes

- Une contrainte circulaire entre `tournament_brackets` et `matches` devait etre ajoutee apres creation de `matches`.
- Les premieres policies de draft permettaient une ecriture directe trop large sur `games` et `moves`.

## Corrections apportees

- Deplacement de la contrainte `tournament_brackets_source_match_fk` apres la creation de `matches`.
- Durcissement RLS : les clients directs ne modifient pas `games` ni `moves`; le backend privilegie reste source de verite.

## Points de securite verifies

- RLS activee sur toutes les tables applicatives.
- Les corrections admin, audit logs, badges et classements recomputes sont reserves aux admins.
- Les joueurs peuvent consulter leurs donnees, invitations, notifications et parties.
- Les spectateurs peuvent lire les parties visibles mais ne peuvent pas jouer.
- Les coups et resultats ne sont pas modifiables directement par les clients.
- Aucun secret reel n'est ajoute.

## Statut final

VALIDE

## Instructions de review

Verifier que :

- les entites couvrent le cahier des charges ;
- les contraintes ne bloquent pas les futurs sprints Django ;
- les policies RLS sont suffisamment strictes pour l'acces direct mobile/admin ;
- les tables Realtime couvrent les besoins de synchronisation ;
- la migration est appliquee sur une instance Supabase locale des que `psql`, Supabase CLI ou Docker Desktop est disponible.
