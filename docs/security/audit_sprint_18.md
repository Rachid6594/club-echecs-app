# Audit securite - Sprint 18

## Verifications

- Authentification JWT configuree par defaut dans DRF.
- Permissions DRF par defaut en `IsAuthenticated`.
- Endpoints publics explicitement declares.
- RLS Supabase initiale documentee.
- Acces direct client aux coups limite par design : backend source de verite.
- Secrets exclus via `.gitignore`.
- `.env.example` contient uniquement des valeurs factices.
- Scan local de secrets execute.
- `npm audit --audit-level=high` execute.

## Risques residuels

- `npm audit` signale une vulnerabilite moderee `postcss` via Next 16.2.9. Aucun correctif non cassant propose par npm au moment du Sprint 18.
- Tests RLS runtime Supabase non executes faute d'instance Supabase locale active.
- Tests E2E navigateur/mobile reels a ajouter quand les endpoints complets seront exposes.

## Recommandations production

- Activer rotation des secrets Supabase et Django.
- Configurer rate limiting login/invitations cote gateway ou backend.
- Activer logs structures sans donnees sensibles.
- Activer alerting sur erreurs 5xx, auth failures et corrections admin.
- Rejouer les migrations Supabase sur environnement staging avant production.

