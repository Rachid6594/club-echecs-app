# Badges et niveaux - Sprint 09

## Catalogue

Le catalogue backend se trouve dans `apps.badges.services.badges`.

Il contient :

- les badges de rang lies aux seuils du classement ;
- les badges de victoire ;
- les badges de serie ;
- les badges competition ;
- les badges activite.

## Attribution automatique

`automatic_badges(context)` retourne les badges dus selon :

- points ;
- victoires ;
- victoires consecutives ;
- champion/finaliste ;
- activite ;
- invincibilite mensuelle ;
- top 10 general ou competition ;
- partie la plus regardee.

`missing_badges(current_codes, context)` filtre les badges deja attribues.

## Assets

Les premiers assets SVG sont presents dans :

- `mobile/assets/badges/`
- `admin-web/public/badges/`

Les sprints UI pourront enrichir les visuels sans changer les codes backend.

