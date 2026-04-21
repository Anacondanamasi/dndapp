-- Run this script once in Supabase SQL Editor.
-- It creates:
-- 1) public.app_update_config table
-- 2) single config row (id = 1)
-- 3) RLS policies (public read, authenticated update)

create table if not exists public.app_update_config (
  id integer primary key check (id = 1),
  latest_version text not null default '1.0.0',
  min_supported_version text not null default '1.0.0',
  optional_update_enabled boolean not null default true,
  title text not null default 'Update available',
  message text not null default 'A new version is available. Please update to continue.',
  android_download_url text,
  ios_download_url text,
  updated_at timestamptz not null default now()
);

create or replace function public.touch_app_update_config_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_touch_app_update_config_updated_at on public.app_update_config;
create trigger trg_touch_app_update_config_updated_at
before update on public.app_update_config
for each row
execute function public.touch_app_update_config_updated_at();

insert into public.app_update_config (
  id,
  latest_version,
  min_supported_version,
  optional_update_enabled,
  title,
  message,
  android_download_url
)
values (
  1,
  '1.0.0',
  '1.0.0',
  true,
  'Update available',
  'A new version of the app is available. Please update now.',
  'https://github.com/Anacondanamasi/dndapp/releases/latest/download/dndapp-latest.apk'
)
on conflict (id) do nothing;

alter table public.app_update_config enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'app_update_config'
      and policyname = 'app_update_public_select'
  ) then
    create policy app_update_public_select
      on public.app_update_config
      for select
      using (true);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'app_update_config'
      and policyname = 'app_update_authenticated_update'
  ) then
    create policy app_update_authenticated_update
      on public.app_update_config
      for update
      to authenticated
      using (
        exists (
          select 1
          from public.profiles p
          where p.id = auth.uid()::text
            and p.is_admin = true
        )
      )
      with check (
        exists (
          select 1
          from public.profiles p
          where p.id = auth.uid()::text
            and p.is_admin = true
        )
      );
  end if;
end $$;

-- Example backend update command:
-- update public.app_update_config
-- set latest_version = '1.0.1',
--     min_supported_version = '1.0.0',
--     android_download_url = 'https://github.com/Anacondanamasi/dndapp/releases/latest/download/dndapp-latest.apk',
--     ios_download_url = 'https://apps.apple.com/app/idXXXXXXXXXX',
--     title = 'New update ready',
--     message = 'We added improvements. Update now for best experience.'
-- where id = 1;
