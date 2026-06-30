# Club Echecs App

Plateforme complete pour un club d'echecs, composee d'un backend Django REST Framework, d'un dashboard admin Next.js, d'une application mobile Flutter et d'une base Supabase PostgreSQL avec Realtime.

## Objectif produit

Le projet vise un produit utilisable par un club d'echecs, pas un MVP. Les fonctionnalites seront livrees sprint par sprint avec tests, documentation et validation Markdown avant de passer au sprint suivant.

## Architecture

```text
club-echecs-app/
|-- backend/
|-- admin-web/
|-- mobile/
|-- supabase/
|-- docs/
|-- .github/workflows/
|-- .env.example
|-- docker-compose.yml
`-- README.md
```

## Regle de progression

Chaque sprint doit etre :

1. implemente ;
2. teste ;
3. corrige ;
4. documente ;
5. valide dans `docs/validations/sprint_XX_validation.md` ;
6. pret pour review.

Le sprint suivant ne doit pas commencer tant que le sprint courant n'est pas valide.

## Branches

Les branches de travail suivent le format :

```text
sprint/XX-nom-du-sprint
```

Exemple :

```text
sprint/00-initialisation-repo
```

## Commits

Les commits de sprint suivent le format :

```text
feat(sprint-XX): description claire
```

## Pull requests

Une pull request de sprint doit contenir :

- le perimetre livre ;
- les tests executes ;
- le lien vers le fichier de validation du sprint ;
- les risques ou points de review ;
- la confirmation qu'aucun secret n'est commite.

## Sprints

Le detail des validations est conserve dans `docs/validations/`.

