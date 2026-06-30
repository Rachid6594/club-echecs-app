# Moteur d'echecs backend - Sprint 05

## Choix technique

Le backend utilise `python-chess` pour la logique de regles. Cela evite de recreer a la main les validations complexes : coups legaux, echec, mat, pat, roque, promotion, prise en passant et fins de partie.

## Service

Le service principal est `ChessGameState` dans `apps.games.services.chess_engine`.

Il expose :

- `play_uci(uci)` : joue un coup UCI valide ou leve `IllegalMoveError`.
- `play_san(san)` : joue un coup SAN valide ou leve `IllegalMoveError`.
- `legal_moves_uci()` : liste les coups legaux.
- `status()` : retourne l'etat courant de la partie.
- `pgn()` : genere un historique PGN depuis les coups joues.

## Donnees retournees par coup

Chaque coup valide retourne un `MoveResult` avec :

- UCI ;
- SAN ;
- FEN avant/apres ;
- numero de coup ;
- couleur ;
- capture ;
- echec ;
- echec et mat ;
- pat ;
- roque ;
- prise en passant ;
- promotion ;
- resultat si la partie est terminee.

## Source de verite

Ce service sera appele par les endpoints de partie lors des sprints suivants. Le client mobile ne doit jamais valider definitivement un coup seul.

