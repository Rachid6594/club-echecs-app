# Sprint 03 - Authentification et profils

## Resume du sprint

Les endpoints d'authentification JWT, la gestion du profil joueur et les roles de base ont ete ajoutes au backend Django.

## Fonctionnalites realisees

- `POST /api/auth/register/`
- `POST /api/auth/login/`
- `POST /api/auth/refresh/`
- `POST /api/auth/logout/`
- `GET /api/auth/me/`
- `PATCH /api/auth/me/`
- Creation du modele `UserProfile`.
- Creation d'une permission role admin `IsAdminRole`.
- Ajout du blacklist des refresh tokens JWT.
- Documentation API auth dans `docs/api/auth.md`.
- Tests API auth.

## Fichiers crees/modifies

- `backend/config/settings/base.py`
- `backend/config/urls.py`
- `backend/apps/accounts/models.py`
- `backend/apps/accounts/admin.py`
- `backend/apps/accounts/migrations/0002_userprofile.py`
- `backend/apps/accounts/permissions.py`
- `backend/apps/accounts/serializers.py`
- `backend/apps/accounts/views.py`
- `backend/apps/accounts/urls.py`
- `backend/tests/conftest.py`
- `backend/tests/test_auth_api.py`
- `docs/api/auth.md`
- `docs/validations/sprint_03_validation.md`

## Tests executes

- Installation des dependances backend deja realisee au Sprint 02.
- `python manage.py check --settings=config.settings.test`
- `python manage.py makemigrations --check --dry-run --settings=config.settings.test`
- `pytest`
- Scan local de secrets evidents.

## Resultats des tests

- `python manage.py check --settings=config.settings.test` : OK, aucun probleme detecte.
- `python manage.py makemigrations --check --dry-run --settings=config.settings.test` : OK, aucun changement manquant.
- `pytest` : OK, 9 tests passes.
- Scan local de secrets evidents : OK.

## Bugs detectes

- Les tests auth utilisaient la base sans marque `django_db`.
- Le test logout reutilisait l'ancien refresh token apres rotation, alors que `BLACKLIST_AFTER_ROTATION=True` le rend invalide.

## Corrections apportees

- Ajout de `pytestmark = pytest.mark.django_db` aux tests auth.
- Mise a jour du test logout pour utiliser le refresh token retourne par `/api/auth/refresh/`.

## Points de securite verifies

- Les endpoints `me`, update profile et logout exigent un utilisateur authentifie.
- Register force le role `player`.
- Le role utilisateur n'est pas modifiable par l'API profil.
- Les emails et usernames sont verifies contre les doublons.
- Les refresh tokens peuvent etre blacklistes au logout.
- JWT reste l'authentification DRF par defaut.
- Aucun secret reel n'est ajoute.

## Statut final

VALIDE

## Instructions de review

Verifier que :

- les endpoints auth retournent les codes attendus ;
- le profil est cree a l'inscription ;
- l'API `me` ne fuit pas de donnees sensibles ;
- le logout blackliste bien le refresh token ;
- les roles admin/joueur sont prets pour les prochaines permissions.
