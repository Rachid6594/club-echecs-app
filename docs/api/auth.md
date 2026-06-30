# API Auth - Sprint 03

Base path: `/api/auth/`

## Register

`POST /api/auth/register/`

Body:

```json
{
  "username": "rachid",
  "email": "rachid@example.com",
  "password": "password-long",
  "display_name": "Rachid"
}
```

Response `201`:

```json
{
  "user": {
    "id": "...",
    "username": "rachid",
    "email": "rachid@example.com",
    "role": "player",
    "is_active": true,
    "profile": {
      "display_name": "Rachid",
      "avatar_url": "",
      "bio": "",
      "country_code": "",
      "club_joined_at": null
    }
  },
  "tokens": {
    "refresh": "...",
    "access": "..."
  }
}
```

## Login

`POST /api/auth/login/`

Body:

```json
{
  "email": "rachid@example.com",
  "password": "password-long"
}
```

## Refresh

`POST /api/auth/refresh/`

Body:

```json
{
  "refresh": "..."
}
```

## Logout

`POST /api/auth/logout/`

Requires `Authorization: Bearer <access>`.

Body:

```json
{
  "refresh": "..."
}
```

The refresh token is blacklisted.

## Me

`GET /api/auth/me/`

Requires `Authorization: Bearer <access>`.

## Update Profile

`PATCH /api/auth/me/`

Requires `Authorization: Bearer <access>`.

Body:

```json
{
  "profile": {
    "display_name": "Rachid K.",
    "bio": "Joueur blitz",
    "country_code": "BF"
  }
}
```
