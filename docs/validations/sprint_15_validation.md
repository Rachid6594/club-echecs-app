# Sprint 15 - Mobile tournois, classement, badges

## Resume du sprint

Les ecrans mobiles tournois, detail tournoi, bracket, classement, badges et notifications ont ete ajoutes.

## Fonctionnalites realisees

- Liste tournois.
- Detail tournoi.
- Preview bracket.
- Classement general.
- Badges.
- Notifications.
- Navigation depuis accueil.
- Tests widgets.

## Fichiers crees/modifies

- `mobile/lib/src/app.dart`
- `mobile/lib/src/screens/tournaments_screen.dart`
- `mobile/lib/src/screens/tournament_detail_screen.dart`
- `mobile/lib/src/screens/rankings_screen.dart`
- `mobile/lib/src/screens/badges_screen.dart`
- `mobile/lib/src/screens/notifications_screen.dart`
- `mobile/lib/src/screens/home_screen.dart`
- `mobile/test/app_test.dart`
- `docs/validations/sprint_15_validation.md`

## Tests executes

- `flutter test`
- `pytest` backend
- Scan local de secrets evidents.

## Resultats des tests

- `flutter test` : OK, 7 tests passes.
- `python manage.py check --settings=config.settings.test` : OK, aucun probleme detecte.
- `pytest` backend : OK, 86 tests passes.
- Scan local de secrets evidents : OK.

## Bugs detectes

- Le test widget devait scroller davantage pour atteindre badges et notifications.

## Corrections apportees

- Scroll explicite ajoute avant les taps sur badges et notifications.

## Points de securite verifies

- Aucun secret ajoute.
- Les donnees affichees restent mockees et ne remplacent pas les validations backend.

## Statut final

VALIDE

## Instructions de review

Verifier que la navigation mobile couvre les ecrans attendus pour le prochain branchement API.
