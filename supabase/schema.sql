-- SafaiSetu private evidence schema
create extension if not exists pgcrypto;
create type user_role as enum ('citizen','worker','admin');
create type complaint_status as enum ('pending','in_progress','resolved');
create table if not exists users (id uuid primary key references auth.users(id) on delete cascade, name text, phone text, role user_role default 'citizen', village_name text);
create table if not exists workers (id uuid primary key default gen_random_uuid(), user_id uuid unique references auth.users(id) on delete set null, name text not null, assigned_area text, total_tasks_completed int default 0);
create table if not exists complaints (id uuid primary key default gen_random_uuid(), user_id uuid references users(id), assigned_worker_id uuid references workers(id) on delete set null, photo_path text, resolution_photo_path text, resolution_notes text, resolved_at timestamptz, location_lat numeric, location_lng numeric, waste_type text not null, description text, ai_confidence numeric, status complaint_status default 'pending', created_at timestamptz default now());
alter table users enable row level security;
alter table workers enable row level security;
alter table complaints enable row level security;
create or replace function public.current_role() returns user_role language sql stable security definer set search_path = public as $$ select role from public.users where id = auth.uid() $$;
create or replace function public.current_worker_id() returns uuid language sql stable security definer set search_path = public as $$ select id from public.workers where user_id = auth.uid() $$;
drop policy if exists "citizens see own and staff see assigned work" on complaints;
drop policy if exists "authenticated citizens can create complaints" on complaints;
drop policy if exists "admins assign and staff update assigned work" on complaints;
create policy "citizens see own and staff see assigned work" on complaints for select using (auth.uid() = user_id or public.current_role() = 'admin' or assigned_worker_id = public.current_worker_id());
create policy "authenticated citizens can create complaints" on complaints for insert with check (auth.uid() = user_id);
create policy "admins assign and staff update assigned work" on complaints for update using (public.current_role() = 'admin' or assigned_worker_id = public.current_worker_id()) with check (public.current_role() = 'admin' or assigned_worker_id = public.current_worker_id());
-- Temporary citizen-owned evidence path update after complaint creation. Restrict the client to only setting photo_path in application code.
drop policy if exists "citizens attach original evidence" on complaints;
create policy "citizens attach original evidence" on complaints for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "staff can view workers" on workers;
create policy "staff can view workers" on workers for select using (public.current_role() in ('admin','worker'));
-- In Supabase Storage, create a PRIVATE bucket named complaint-photos.
-- Storage read policy: authenticated users may read only when they can see the matching complaint.
create policy "authorized users read complaint evidence" on storage.objects for select using (bucket_id = 'complaint-photos' and (split_part(name, '/', 1)::uuid in (select id from public.complaints where auth.uid() = user_id or public.current_role() = 'admin' or assigned_worker_id = public.current_worker_id())));
create policy "citizens upload original evidence" on storage.objects for insert with check (bucket_id = 'complaint-photos' and split_part(name, '/', 1)::uuid in (select id from public.complaints where auth.uid() = user_id));
create policy "assigned staff upload resolution evidence" on storage.objects for insert with check (bucket_id = 'complaint-photos' and split_part(name, '/', 1)::uuid in (select id from public.complaints where public.current_role() = 'admin' or assigned_worker_id = public.current_worker_id()));
