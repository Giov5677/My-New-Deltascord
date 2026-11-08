-- Deltascord: esquema inicial.
-- Execute no SQL Editor do Supabase. Não coloque service_role no aplicativo.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null unique,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile"
on public.profiles for select
to authenticated
using (auth.uid() = id);

create or replace function public.deltascord_create_profile()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  nick text;
begin
  nick := split_part(coalesce(new.email, ''), '@', 1);
  insert into public.profiles (id, nickname)
  values (new.id, nick);
  return new;
end;
$$;

create or replace function public.deltascord_limit_users()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  account_count integer;
begin
  perform pg_advisory_xact_lock(741258963);
  select count(*) into account_count from auth.users;
  if account_count >= 5 then
    raise exception 'Deltascord atingiu o limite de 5 contas.';
  end if;
  return new;
end;
$$;

drop trigger if exists deltascord_limit_users on auth.users;
create trigger deltascord_limit_users
before insert on auth.users
for each row execute function public.deltascord_limit_users();

drop trigger if exists deltascord_new_profile on auth.users;
create trigger deltascord_new_profile
after insert on auth.users
for each row execute function public.deltascord_create_profile();
