# Tournois elimination directe - Sprint 10

## Service

Le service `apps.tournaments.services.single_elimination` gere :

- validation du nombre de joueurs ;
- calcul de taille de bracket ;
- tirage aleatoire seedable ;
- byes ;
- generation du premier round ;
- validation des vainqueurs ;
- generation du round suivant ;
- detection du champion ;
- bonus competition.

## Bonus

Les bonus suivent le cahier des charges :

- Champion : +50
- Finaliste : +30
- Demi-finaliste : +15
- Participation : +5

Ils s'ajoutent au classement general via le service de ranking du Sprint 08.

## Integration future

Le service est volontairement pur pour etre teste sans base. Les endpoints admin de creation tournoi et generation de tableau utiliseront ce noyau lors du Sprint 16.

