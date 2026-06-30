# Sprint 13 - Mobile Flutter fondation

## Resume du sprint

L'application mobile Flutter a ete initialisee avec splash, login, register, home, profil, navigation, client API et tests widgets.

## Fonctionnalites realisees

- Configuration Flutter.
- Splash screen.
- Login.
- Register.
- Accueil joueur.
- Profil joueur.
- Navigation par routes nommees.
- Client API auth de base.
- Assets badges declares.
- Tests widgets.

## Fichiers crees/modifies

- `mobile/pubspec.yaml`
- `mobile/lib/main.dart`
- `mobile/lib/src/app.dart`
- `mobile/lib/src/api/api_client.dart`
- `mobile/lib/src/screens/*.dart`
- `mobile/test/app_test.dart`
- `docs/validations/sprint_13_validation.md`

## Tests executes

- `flutter pub get`
- `flutter test`
- Scan local de secrets evidents.

## Resultats des tests

- `flutter pub get` : OK.
- `flutter test` : OK, 3 tests passes.
- `python manage.py check --settings=config.settings.test` : OK, aucun probleme detecte.
- `pytest` backend : OK, 86 tests passes.
- Scan local de secrets evidents : OK.

## Bugs detectes

- Les premiers tests widget cherchaient un element hors viewport dans la grille de l'accueil.

## Corrections apportees

- Les assertions widget ont ete stabilisees sur des textes visibles dans le viewport initial.

## Points de securite verifies

- Aucun secret API n'est commite.
- L'URL API mobile est configurable avec `MOBILE_API_BASE_URL`.
- Aucun token n'est stocke en dur.

## Statut final

VALIDE

## Instructions de review

Verifier que la navigation correspond aux attentes de la fondation mobile avant les ecrans jeu/tournoi.
