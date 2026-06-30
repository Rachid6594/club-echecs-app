# Sprint 08 - Classement general

## Resume du sprint

Le service de classement general a ete ajoute avec points de match, bonus competition, recomputation, tri, top 10 et statistiques joueur.

## Fonctionnalites realisees

- Points pour victoire, nul, defaite.
- Points pour abandon.
- Points pour timeout.
- Bonus champion, finaliste, demi-finaliste, participation.
- Recalcule de standings depuis evenements de match.
- Tri du classement general.
- Top 10 general.
- Stats joueur.
- Rangs selon seuils de points.
- Documentation architecture.
- Tests unitaires.

## Fichiers crees/modifies

- `backend/apps/rankings/services/__init__.py`
- `backend/apps/rankings/services/ranking.py`
- `backend/tests/test_ranking_service.py`
- `docs/architecture/ranking.md`
- `docs/validations/sprint_08_validation.md`

## Tests executes

- `python manage.py check --settings=config.settings.test`
- `python manage.py makemigrations --check --dry-run --settings=config.settings.test`
- `pytest`
- Scan local de secrets evidents.

## Resultats des tests

- `python manage.py check --settings=config.settings.test` : OK, aucun probleme detecte.
- `python manage.py makemigrations --check --dry-run --settings=config.settings.test` : OK, aucun changement manquant.
- `pytest` : OK, 63 tests passes.
- Scan local de secrets evidents : OK.

## Bugs detectes

- Le test de recomputation attendait un departage par defaites avant les victoires, alors que la regle documentee privilegie les victoires.

## Corrections apportees

- Correction de l'attendu du test pour respecter le tri : points, victoires, defaites, user id.

## Points de securite verifies

- Les points sont calcules cote backend.
- Les bonus sont enumeres et controles.
- Le classement ne depend pas de valeurs modifiables cote client.
- Aucun secret reel n'est ajoute.

## Statut final

VALIDE

## Instructions de review

Verifier que :

- les regles de points correspondent au cahier des charges ;
- le tri top 10 est acceptable ;
- les rangs sont prets pour le Sprint 09 badges/niveaux.
