-- SafaiSetu Supabase schema
create type user_role as enum ('citizen','worker','admin');
create type complaint_status as enum ('pending','in_progress','resolved');
create table if not exists users (id uuid primary key references auth.users(id) on delete cascade, name text, phone text, role user_role default 'citizen', village_name text);
create table if not exists workers (id uuid primary key default gen_random_uuid(), name text not null, assigned_area text, total_tasks_completed int default 0);
create table if not exists complaints (id uuid primary key default gen_random_uuid(), user_id uuid references users(id), photo_url text, location_lat numeric, location_lng numeric, waste_type text not null, status complaint_status default 'pending', created_at timestamptz default now());
alter table complaints enable row level security;
create policy "public can view complaints" on complaints for select using (true);
create policy "authenticated can create complaints" on complaints for insert with check (auth.uid() = user_id or user_id is null);
create policy "admins can update complaints" on complaints for update using (true);
-- Create a public Storage bucket named complaint-photos in the Supabase dashboard.
