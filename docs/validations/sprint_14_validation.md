# Sprint 14 - Mobile jeu et spectateur

## Resume du sprint

Les ecrans mobiles de jeu, horloge, proposition de nul, abandon, matchs en direct et vue spectateur ont ete ajoutes.

## Fonctionnalites realisees

- Ecran echiquier.
- Horloge de partie.
- Proposition de nul.
- Confirmation abandon.
- Liste matchs en direct.
- Vue spectateur.
- Compteur spectateurs/vues mocke.
- Navigation depuis l'accueil.
- Service mobile Game API minimal.
- Tests widgets.

## Fichiers crees/modifies

- `mobile/lib/src/app.dart`
- `mobile/lib/src/api/game_api.dart`
- `mobile/lib/src/screens/game_screen.dart`
- `mobile/lib/src/screens/live_matches_screen.dart`
- `mobile/lib/src/screens/spectator_screen.dart`
- `mobile/lib/src/screens/home_screen.dart`
- `mobile/test/app_test.dart`
- `docs/validations/sprint_14_validation.md`

## Tests executes

- `flutter test`
- `pytest` backend
- Scan local de secrets evidents.

## Resultats des tests

- `flutter test` : OK, 5 tests passes.
- `python manage.py check --settings=config.settings.test` : OK, aucun probleme detecte.
- `pytest` backend : OK, 86 tests passes.
- Scan local de secrets evidents : OK.

## Bugs detectes

- Les tuiles jeu/spectateur etaient initialement hors viewport dans les tests widget.
- Le bouton de proposition de nul etait sous l'echiquier dans le viewport de test.

## Corrections apportees

- Accueil rendu plus compact avec `childAspectRatio`.
- Test widget mis a jour pour scroller avant de toucher l'action de nul.

## Points de securite verifies

- Aucun secret ajoute.
- Les actions jeu sont preparees pour appel backend, pas resolues cote client.

## Statut final

VALIDE

## Instructions de review

Verifier que le parcours mobile jeu/spectateur est coherent avant branchement Realtime.
