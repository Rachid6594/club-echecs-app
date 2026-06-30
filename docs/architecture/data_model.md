# Modele de donnees - Sprint 01

## Principes

La base Supabase PostgreSQL stocke l'etat persistant et diffuse les evenements Realtime. Le backend Django reste la source de verite pour la validation des coups, les scores, les corrections admin et la logique metier.

## Entites principales

- `app_users` : compte applicatif lie optionnellement a `auth.users` via `auth_user_id`.
- `user_profiles` : donnees publiques joueur, statistiques agregees et progression.
- `club_members` : statut d'adhesion au club.
- `tournaments` : competitions, format, statut, controles de temps.
- `tournament_registrations` : inscriptions de joueurs.
- `tournament_stages`, `tournament_groups`, `tournament_brackets` : structure des competitions.
- `matches` : rencontre sportive, liee ou non a un tournoi.
- `games` : partie d'echecs jouee en temps reel.
- `moves` : historique immuable des coups valides.
- `game_clocks` : horloge active et temps restant.
- `invitations` : invitations de match amical.
- `spectator_sessions` et `game_views` : presence live et vues totales.
- `rankings` et `competition_rankings` : classements general et competition.
- `badges` et `user_badges` : badges visuels, rangs et attribution.
- `notifications` : notifications internes.
- `audit_logs`, `disputes`, `admin_corrections` : tracabilite, litiges et corrections.

## Relations clefs

- Un `app_user` possede un seul `user_profile`, un seul `club_member` et une ligne de `rankings`.
- Un `tournament` possede plusieurs inscriptions, stages, groupes, brackets, matches et classements competition.
- Un `match` peut produire une `game`.
- Une `game` possede plusieurs `moves`, une `game_clock`, plusieurs sessions spectateur et plusieurs vues.
- Une `admin_correction` cible une partie ou un match et peut etre liee a un litige.

## Contraintes importantes

- Un joueur ne peut pas jouer contre lui-meme.
- Une invitation pending unique est autorisee pour une paire sender/receiver.
- Les scores de match sont limites aux valeurs attendues par le systeme de points.
- Les classements ne peuvent pas avoir de statistiques negatives.
- Les coups sont uniques par partie, numero et couleur.
- Les corrections admin doivent avoir une cible et conserver l'etat precedent et corrige en JSONB.

## Index

Les index Sprint 01 couvrent :

- auth et roles ;
- statuts des membres, tournois, matches et parties ;
- listes de joueurs et parties ;
- historique de coups par partie ;
- invitations envoyees/recues ;
- presence spectateur live ;
- top classements general et competition ;
- notifications non lues ;
- audit par entite.

## Realtime

Les tables ajoutees a `supabase_realtime` sont :

- `games`
- `moves`
- `game_clocks`
- `invitations`
- `spectator_sessions`
- `notifications`
- `tournament_brackets`
- `matches`

Ces tables couvrent la synchronisation des coups, le statut de partie, les horloges, les invitations, les spectateurs, les notifications et les tableaux de tournoi.

