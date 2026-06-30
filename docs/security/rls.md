# RLS Supabase - Sprint 01

## Objectif

Les politiques RLS protegent l'acces direct depuis le mobile ou le dashboard. Elles ne remplacent pas les validations backend : Django valide toujours les coups, les scores, les droits metier et les corrections.

## Fonctions helper

- `current_app_user_id()` mappe `auth.uid()` vers `app_users.id`.
- `current_app_role()` recupere le role depuis les claims JWT ou `app_users`.
- `is_admin()` autorise les roles `admin` et `super_admin`.

## Regles initiales

- Un joueur peut lire son compte, son profil, ses invitations, ses notifications et ses parties.
- Les membres actifs et classements sont visibles pour les besoins club.
- Les spectateurs peuvent lire les parties actives ou terminees, mais ne peuvent pas jouer.
- Les coups et l'etat des parties sont ecrits par le backend ou un admin via un contexte privilegie ; les clients directs s'abonnent en lecture Realtime.
- Les corrections, litiges admin, badges, classements recomputes et audit logs sont reserves aux admins.
- Les inscriptions tournoi sont possibles uniquement quand le tournoi est ouvert.

## Points a renforcer dans les prochains sprints

- Ajouter des tests automatises RLS contre une instance Supabase locale.
- Ajouter des RPC controlees si une ecriture directe Supabase devient necessaire cote mobile.
- Ajouter rate limiting applicatif sur login et invitations cote backend.
- Verifier les claims JWT emis par le backend avant activation production.
