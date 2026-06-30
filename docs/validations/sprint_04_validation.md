# Sprint 04 - Membres du club et invitations

## Resume du sprint

Les membres du club et les invitations de match entre membres ont ete ajoutes au backend, avec endpoints REST, contraintes, expiration et tests.

## Fonctionnalites realisees

- Modele `ClubMember`.
- Modele `Invitation`.
- Liste des membres actifs.
- Recherche membre par username, email ou display name.
- Detail membre.
- Stats membre initiales.
- Creation d'invitation via detail membre.
- Creation d'invitation directe par `receiver_id`.
- Acceptation d'invitation.
- Refus d'invitation.
- Annulation d'invitation.
- Listes invitations recues et envoyees.
- Expiration automatique lors de la consultation/action.
- Documentation API membres/invitations.
- Tests API Sprint 04.

## Fichiers crees/modifies

- `backend/config/urls.py`
- `backend/apps/clubs/models.py`
- `backend/apps/clubs/admin.py`
- `backend/apps/clubs/migrations/0001_initial.py`
- `backend/apps/clubs/migrations/__init__.py`
- `backend/apps/clubs/serializers.py`
- `backend/apps/clubs/views.py`
- `backend/apps/clubs/urls.py`
- `backend/tests/test_members_invitations_api.py`
- `docs/api/members_invitations.md`
- `docs/validations/sprint_04_validation.md`

## Tests executes

- `python manage.py check --settings=config.settings.test`
- `python manage.py makemigrations --check --dry-run --settings=config.settings.test`
- `pytest`
- Scan local de secrets evidents.

## Resultats des tests

- `python manage.py check --settings=config.settings.test` : OK, aucun probleme detecte.
- `python manage.py makemigrations --check --dry-run --settings=config.settings.test` : OK, aucun changement manquant.
- `pytest` : OK, 17 tests passes.
- Scan local de secrets evidents : OK.

## Bugs detectes

- Le champ `expires_at` utilisait un default non aligne entre modele et migration.
- Le doublon d'invitation pending etait d'abord capture via `IntegrityError`, ce qui cassait la transaction de test.

## Corrections apportees

- Alignement du default d'expiration via `default_invitation_expiry`.
- Ajout d'une verification applicative avant creation pour bloquer proprement les doublons pending.

## Points de securite verifies

- Tous les endpoints membres/invitations exigent une authentification.
- Un joueur ne peut pas s'inviter lui-meme.
- Un joueur ne peut inviter qu'un membre actif.
- Un doublon d'invitation pending est bloque.
- Seul le destinataire peut accepter/refuser.
- Seul l'expediteur peut annuler.
- Une invitation expiree ne peut plus etre acceptee.
- Aucun secret reel n'est ajoute.

## Statut final

VALIDE

## Instructions de review

Verifier que :

- la recherche membre est suffisante pour le mobile ;
- les permissions d'action invitation sont strictes ;
- l'expiration fonctionne ;
- la creation de partie apres acceptation est bien laissee au Sprint 05/06.
