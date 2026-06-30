# Supabase Realtime - Sprint 07

## Objectif

Le Sprint 07 definit les contrats Realtime utilises par le backend et les clients pour synchroniser les parties, spectateurs, invitations, notifications et tableaux de tournoi.

## Channels

- `game:{game_id}` : coups, statut de partie, horloge.
- `game:{game_id}:spectators` : presence spectateurs et compteur live.
- `user:{user_id}:invitations` : invitations recues/envoyees.
- `user:{user_id}:notifications` : notifications internes.
- `tournament:{tournament_id}:bracket` : mise a jour tableau tournoi.

## Events

- `move_played`
- `game_status`
- `clock_updated`
- `spectator_joined`
- `spectator_left`
- `view_count_updated`
- `invitation_updated`
- `notification_created`
- `tournament_bracket_updated`

## Reconnexion

La configuration backend expose :

- `SUPABASE_REALTIME_RECONNECT_ATTEMPTS`
- `SUPABASE_REALTIME_RECONNECT_BACKOFF_MS`

Les payloads de broadcast embarquent la policy de reconnexion attendue afin que mobile/admin puissent appliquer le meme comportement.

## Source de verite

Le backend valide les coups avant tout broadcast `move_played`. Supabase Realtime diffuse l'etat valide, mais ne remplace pas les validations Django.

## Limite du sprint

Les tests Sprint 07 valident les contrats de channels/payloads et la configuration. Un test d'integration contre une instance Supabase active sera ajoute quand l'environnement Supabase local sera disponible.

