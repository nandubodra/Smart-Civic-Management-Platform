-- SafaiSetu Supabase schema
create extension if not exists pgcrypto;
create type user_role as enum ('citizen','worker','admin');
create type complaint_status as enum ('pending','in_progress','resolved');
create table if not exists users (id uuid primary key references auth.users(id) on delete cascade, name text, phone text, role user_role default 'citizen', village_name text);
create table if not exists workers (id uuid primary key default gen_random_uuid(), name text not null, assigned_area text, total_tasks_completed int default 0);
create table if not exists complaints (id uuid primary key default gen_random_uuid(), user_id uuid references users(id), photo_url text, location_lat numeric, location_lng numeric, waste_type text not null, status complaint_status default 'pending', created_at timestamptz default now());
alter table users enable row level security;
alter table workers enable row level security;
alter table complaints enable row level security;
create or replace function public.current_role() returns user_role language sql stable security definer set search_path = public as $$ select role from public.users where id = auth.uid() $$;
create policy "citizens can view own complaints" on complaints for select using (auth.uid() = user_id or public.current_role() in ('admin','worker'));
create policy "authenticated citizens can create complaints" on complaints for insert with check (auth.uid() = user_id);
create policy "admins and workers can update complaints" on complaints for update using (public.current_role() in ('admin','worker'));
create policy "users can view own profile" on users for select using (auth.uid() = id or public.current_role() in ('admin','worker'));
create policy "workers and admins can view workers" on workers for select using (public.current_role() in ('admin','worker'));
-- Create a public Storage bucket named complaint-photos, then add storage policies for authenticated users.
