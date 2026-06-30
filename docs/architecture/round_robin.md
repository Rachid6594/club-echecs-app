# Championnat round-robin - Sprint 11

## Service

Le service `apps.tournaments.services.round_robin` gere :

- generation des matchs entre tous les inscrits ;
- support des joueurs impairs avec bye ;
- alternance simple des couleurs ;
- saisie de resultat ;
- classement competition ;
- departage par victoires puis Sonneborn-Berger simplifie.

## Classement competition

Le tri utilise :

1. points ;
2. victoires ;
3. Sonneborn-Berger ;
4. defaites ;
5. identifiant joueur.

## Limite

Le service est pur et sera branche aux modeles persistants de tournoi lors de l'integration admin/API.

