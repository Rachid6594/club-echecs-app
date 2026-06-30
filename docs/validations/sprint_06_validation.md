# Sprint 06 - Horloge et fins de partie

## Resume du sprint

Les services backend d'horloge, de formats de temps, d'abandon, de timeout, de proposition de nul et de conversion d'etat d'echecs vers resultat ont ete ajoutes.

## Fonctionnalites realisees

- Formats 1+0, 3+2, 5+0, 10+5, 15+10.
- Format personnalise via `TimeControl`.
- Horloge `GameClock`.
- Decrement du temps actif.
- Increment apres coup.
- Detection du temps ecoule.
- Resultat par abandon.
- Proposition de nul.
- Acceptation de nul.
- Refus de nul.
- Attribution des points selon les regles du cahier des charges.
- Conversion checkmate/stalemate depuis le moteur d'echecs.
- Tests unitaires.
- Documentation architecture.

## Fichiers crees/modifies

- `backend/apps/games/services/game_lifecycle.py`
- `backend/tests/test_game_lifecycle.py`
- `docs/architecture/game_lifecycle.md`
- `docs/validations/sprint_06_validation.md`

## Tests executes

- `python manage.py check --settings=config.settings.test`
- `python manage.py makemigrations --check --dry-run --settings=config.settings.test`
- `pytest`
- Scan local de secrets evidents.

## Resultats des tests

- `python manage.py check --settings=config.settings.test` : OK, aucun probleme detecte.
- `python manage.py makemigrations --check --dry-run --settings=config.settings.test` : OK, aucun changement manquant.
- `pytest` : OK, 34 tests passes.
- Scan local de secrets evidents : OK.

## Bugs detectes

- Aucun bug detecte pendant le Sprint 06.

## Corrections apportees

- Aucune correction necessaire apres execution des tests.

## Points de securite verifies

- Les resultats et points sont calcules cote backend.
- Le timeout et l'abandon ne dependent pas du client.
- Le joueur qui propose un nul ne peut pas accepter/refuser sa propre proposition.
- Aucun secret reel n'est ajoute.

## Statut final

VALIDE

## Instructions de review

Verifier que :

- les formats de temps correspondent aux exigences ;
- les points sont attribues correctement ;
- la logique est prete a etre branchee aux endpoints de partie.
