# Monitoring et exploitation

## Logs a suivre

- Erreurs API 4xx/5xx.
- Echecs login.
- Spam invitation.
- Coups refuses.
- Timeouts et fins de partie.
- Corrections admin.
- Erreurs Realtime.

## Alertes recommandees

- Hausse 5xx backend.
- Latence API elevee.
- Echec connexion Supabase.
- Build Vercel echoue.
- Nombre anormal de corrections admin.

## Donnees sensibles

Les logs ne doivent pas contenir :

- mots de passe ;
- tokens JWT ;
- cles Supabase ;
- emails dans traces techniques non necessaires ;
- payloads complets contenant donnees privees.

