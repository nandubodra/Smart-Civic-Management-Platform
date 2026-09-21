-- SafaiSetu private evidence security migration
create extension if not exists pgcrypto;

-- Safe for existing databases: add private path columns without deleting legacy URL data.
alter table public.complaints add column if not exists photo_path text;
alter table public.complaints add column if not exists resolution_photo_path text;
alter table public.complaints add column if not exists resolution_notes text;
alter table public.complaints add column if not exists resolved_at timestamptz;

alter table public.users enable row level security;
alter table public.workers enable row level security;
alter table public.complaints enable row level security;

create or replace function public.current_role()
returns user_role
language sql stable security definer set search_path = public
as $$ select role from public.users where id = auth.uid() $$;

create or replace function public.current_worker_id()
returns uuid
language sql stable security definer set search_path = public
as $$ select id from public.workers where user_id = auth.uid() $$;

-- Keep complaint access scoped to the citizen, assigned worker, or admin.
drop policy if exists "public can view complaints" on public.complaints;
drop policy if exists "citizens see own and staff see assigned work" on public.complaints;
drop policy if exists "authenticated citizens can create complaints" on public.complaints;
drop policy if exists "admins and workers can update complaints" on public.complaints;
drop policy if exists "admins assign and staff update assigned work" on public.complaints;
drop policy if exists "citizens attach original evidence" on public.complaints;

create policy "citizens see own and staff see assigned work"
on public.complaints for select
using (auth.uid() = user_id or public.current_role() = 'admin' or assigned_worker_id = public.current_worker_id());

create policy "authenticated citizens can create complaints"
on public.complaints for insert
with check (auth.uid() = user_id);

create policy "admins assign and staff update assigned work"
on public.complaints for update
using (public.current_role() = 'admin' or assigned_worker_id = public.current_worker_id())
with check (public.current_role() = 'admin' or assigned_worker_id = public.current_worker_id());

-- Citizens may attach only their original evidence after creating a complaint.
create policy "citizens attach original evidence"
on public.complaints for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Create this bucket as PRIVATE in Supabase Storage before using the app.
insert into storage.buckets (id, name, public)
values ('complaint-photos', 'complaint-photos', false)
on conflict (id) do update set public = false;

drop policy if exists "authorized users read complaint evidence" on storage.objects;
drop policy if exists "citizens upload original evidence" on storage.objects;
drop policy if exists "assigned staff upload resolution evidence" on storage.objects;

-- Storage paths are complaints/<complaint-uuid>/filename. The complaint UUID is segment 2.
create policy "authorized users read complaint evidence"
on storage.objects for select
using (
  bucket_id = 'complaint-photos'
  and split_part(name, '/', 2)::uuid in (
    select id from public.complaints
    where auth.uid() = user_id
       or public.current_role() = 'admin'
       or assigned_worker_id = public.current_worker_id()
  )
);

create policy "citizens upload original evidence"
on storage.objects for insert
with check (
  bucket_id = 'complaint-photos'
  and split_part(name, '/', 2)::uuid in (
    select id from public.complaints where auth.uid() = user_id
  )
  and split_part(name, '/', 3) like 'original-%'
);

create policy "assigned staff upload resolution evidence"
on storage.objects for insert
with check (
  bucket_id = 'complaint-photos'
  and split_part(name, '/', 2)::uuid in (
    select id from public.complaints
    where public.current_role() = 'admin'
       or assigned_worker_id = public.current_worker_id()
  )
  and split_part(name, '/', 3) like 'resolution-%'
);

create index if not exists complaints_user_id_idx on public.complaints(user_id);
create index if not exists complaints_assigned_worker_id_idx on public.complaints(assigned_worker_id);
