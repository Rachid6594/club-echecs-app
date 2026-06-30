# Backend

Backend Django + Django REST Framework.

## Installation locale

```bash
python -m venv .venv
.venv/Scripts/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

## Tests

```bash
pytest
```

## Settings

- `config.settings.local` : developpement local.
- `config.settings.test` : tests automatises.
- `config.settings.production` : production.

## Endpoint de sante

```text
GET /api/health/
```
