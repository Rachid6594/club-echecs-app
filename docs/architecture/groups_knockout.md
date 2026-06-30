# Groupes + phase finale - Sprint 12

## Service

Le service `apps.tournaments.services.groups_knockout` combine :

- tirage des groupes ;
- generation des matchs de groupe via round-robin ;
- classement par groupe ;
- qualification des meilleurs ;
- generation de la phase finale via elimination directe.

## Regles

- Minimum 4 joueurs.
- Minimum 2 groupes.
- Minimum 1 qualifie par groupe.
- Joueurs uniques.
- Le classement de groupe reutilise le departage round-robin.

## Integration future

Les endpoints admin pourront utiliser ce service pour preparer les groupes et generer automatiquement la phase finale apres validation des matchs de groupe.

