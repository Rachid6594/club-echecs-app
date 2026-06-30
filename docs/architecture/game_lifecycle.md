# Horloge et fins de partie - Sprint 06

## Perimetre

Le Sprint 06 ajoute les services backend responsables de l'horloge et des fins de partie :

- formats de temps standards ;
- temps personnalise ;
- decrement du temps actif ;
- increment apres coup ;
- timeout ;
- abandon ;
- proposition de nul ;
- acceptation/refus du nul ;
- resultat automatique depuis l'etat du moteur d'echecs.

## Formats supportes

- Bullet 1+0
- Blitz 3+2
- Blitz 5+0
- Rapide 10+5
- Rapide 15+10
- Personnalise via `TimeControl`

## Points de match

- Victoire : 3 points
- Nul : 1 point par joueur
- Defaite : 0 point
- Abandon : 0 point pour le joueur qui abandonne, 3 pour l'adversaire
- Temps ecoule : 0 point pour le joueur flag, 3 pour l'adversaire

## Integration future

Les services seront branches aux endpoints `Game` lors des prochains sprints. Ils ne dependent pas encore de la base afin de rester simples a tester et reutilisables.

