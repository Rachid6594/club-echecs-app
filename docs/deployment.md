# Deploiement

## Admin Web - Vercel

1. Importer le repo GitHub `Rachid6594/club-echecs-app`.
2. Configurer le root directory sur `admin-web`.
3. Build command : `npm run build`.
4. Variables :
   - `NEXT_PUBLIC_API_BASE_URL`
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`

## Backend Django

Le backend peut etre deploye sur une plateforme compatible ASGI/WSGI.

Variables :

- `DJANGO_SECRET_KEY`
- `DJANGO_DEBUG=false`
- `DJANGO_ALLOWED_HOSTS`
- `DATABASE_URL`
- `CORS_ALLOWED_ORIGINS`
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

Commandes :

```bash
pip install -r backend/requirements.txt
python backend/manage.py migrate --settings=config.settings.production
python backend/manage.py collectstatic --noinput --settings=config.settings.production
```

## Supabase

1. Creer le projet Supabase.
2. Appliquer `supabase/migrations/0001_core_schema.sql`.
3. Appliquer `supabase/policies/0001_initial_rls.sql`.
4. Verifier Realtime sur les tables configurees.
5. Configurer les cles dans les environnements backend/admin/mobile.

## Mobile Flutter

```bash
cd mobile
flutter pub get
flutter test
flutter build apk
```

## Rollback

- Vercel : rollback vers le deploiement precedent.
- Backend : redeployer l'image/release precedente.
- Supabase : appliquer une migration corrective ; ne pas supprimer de donnees sans backup.

