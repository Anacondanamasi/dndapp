-- Run this script once in Supabase SQL Editor.
-- It creates:
-- 1) public.home_banners table
-- 2) public storage bucket: home-banners
-- 3) RLS policies for reading and admin CRUD

create table if not exists public.home_banners (
  id text primary key,
  image_url text not null,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists idx_home_banners_sort_order
  on public.home_banners (sort_order, created_at);

alter table public.home_banners enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'home_banners'
      and policyname = 'home_banners_public_select'
  ) then
    create policy home_banners_public_select
      on public.home_banners
      for select
      using (true);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'home_banners'
      and policyname = 'home_banners_authenticated_all'
  ) then
    create policy home_banners_authenticated_all
      on public.home_banners
      for all
      to authenticated
      using (true)
      with check (true);
  end if;
end $$;

insert into storage.buckets (id, name, public)
values ('home-banners', 'home-banners', true)
on conflict (id) do nothing;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'home_banners_public_read'
  ) then
    create policy home_banners_public_read
      on storage.objects
      for select
      using (bucket_id = 'home-banners');
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'home_banners_authenticated_insert'
  ) then
    create policy home_banners_authenticated_insert
      on storage.objects
      for insert
      to authenticated
      with check (bucket_id = 'home-banners');
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'home_banners_authenticated_update'
  ) then
    create policy home_banners_authenticated_update
      on storage.objects
      for update
      to authenticated
      using (bucket_id = 'home-banners')
      with check (bucket_id = 'home-banners');
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'home_banners_authenticated_delete'
  ) then
    create policy home_banners_authenticated_delete
      on storage.objects
      for delete
      to authenticated
      using (bucket_id = 'home-banners');
  end if;
end $$;
