# Notifications - Sprint 17

## Types

- Invitation recue
- Rappel de partie
- Debut competition
- Match genere
- Resultat
- Badge gagne

## Service

Le service `apps.notifications.services.notifications` genere des notifications typees avec payload JSON stable. Les endpoints persistants et les broadcasts Realtime utiliseront ces objets dans les sprints d'integration.

## Securite

Les notifications sont generees cote backend. Le client ne decide pas des resultats, badges ou rappels de competition.

