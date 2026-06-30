# API Membres et Invitations - Sprint 04

All endpoints require `Authorization: Bearer <access>`.

## Membres

`GET /api/members/`

Query params:

- `search` : filtre sur username, email ou display name.

`GET /api/members/{member_id}/`

Retourne le detail d'un membre actif.

`GET /api/members/{member_id}/stats/`

Retourne les statistiques du membre. Les valeurs restent a zero au Sprint 04 ; elles seront branchees aux parties et classements dans les sprints suivants.

`POST /api/members/{member_id}/invite/`

Body:

```json
{
  "proposed_initial_seconds": 300,
  "proposed_increment_seconds": 2,
  "message": "Blitz ?"
}
```

## Invitations

`POST /api/invitations/`

Body:

```json
{
  "receiver_id": "...",
  "proposed_initial_seconds": 600,
  "proposed_increment_seconds": 0
}
```

`GET /api/invitations/received/`

Liste les invitations recues.

`GET /api/invitations/sent/`

Liste les invitations envoyees.

`POST /api/invitations/{invitation_id}/accept/`

Accepte une invitation. Seul le destinataire peut le faire.

`POST /api/invitations/{invitation_id}/reject/`

Refuse une invitation. Seul le destinataire peut le faire.

`POST /api/invitations/{invitation_id}/cancel/`

Annule une invitation. Seul l'expediteur peut le faire.

## Regles

- Impossible de s'inviter soi-meme.
- Le destinataire doit etre un membre actif.
- Une seule invitation pending est autorisee par paire expediteur/destinataire.
- Une invitation expiree passe a `expired` et ne peut plus etre acceptee.

