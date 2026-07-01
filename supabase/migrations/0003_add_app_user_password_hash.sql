alter table public.app_users
add column if not exists password_hash text;

create unique index if not exists app_users_email_lower_key
on public.app_users (lower(email));

create unique index if not exists app_users_username_lower_key
on public.app_users (lower(username));
