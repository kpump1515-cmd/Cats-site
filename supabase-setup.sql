-- Children Are Future Successors: staff editing setup
-- Paste this whole script into Supabase > SQL Editor > New query, then press Run.

-- EVENTS
create table if not exists public.events (
  id bigint generated always as identity primary key,
  title text not null,
  when_text text,          -- what visitors see, e.g. "November" or "Sat, Nov 21 - 2:00 PM"
  sort_date date,          -- optional, used to put events in order
  details text,
  created_at timestamptz not null default now()
);
alter table public.events enable row level security;
drop policy if exists "events public read" on public.events;
drop policy if exists "events staff write" on public.events;
create policy "events public read" on public.events for select to anon, authenticated using (true);
create policy "events staff write" on public.events for all to authenticated using (true) with check (true);

-- PHOTOS
create table if not exists public.photos (
  id bigint generated always as identity primary key,
  url text not null,
  path text,
  caption text,
  created_at timestamptz not null default now()
);
alter table public.photos enable row level security;
drop policy if exists "photos public read" on public.photos;
drop policy if exists "photos staff write" on public.photos;
create policy "photos public read" on public.photos for select to anon, authenticated using (true);
create policy "photos staff write" on public.photos for all to authenticated using (true) with check (true);

-- PHOTO STORAGE BUCKET
insert into storage.buckets (id, name, public) values ('photos', 'photos', true)
on conflict (id) do update set public = true;
drop policy if exists "photos bucket public read" on storage.objects;
drop policy if exists "photos bucket staff upload" on storage.objects;
drop policy if exists "photos bucket staff update" on storage.objects;
drop policy if exists "photos bucket staff delete" on storage.objects;
create policy "photos bucket public read" on storage.objects for select to public using (bucket_id = 'photos');
create policy "photos bucket staff upload" on storage.objects for insert to authenticated with check (bucket_id = 'photos');
create policy "photos bucket staff update" on storage.objects for update to authenticated using (bucket_id = 'photos');
create policy "photos bucket staff delete" on storage.objects for delete to authenticated using (bucket_id = 'photos');

-- STARTING EVENTS (the ones already on the site)
insert into public.events (title, when_text, sort_date)
select * from (values
  ('Kids Feed the Homeless', 'November - TBA', date '2026-11-30'),
  ('Kids Coat Drive', 'December - TBA', date '2026-12-31'),
  ('Mid Term School Drive', 'January - TBA', date '2027-01-31')
) v(title, when_text, sort_date)
where not exists (select 1 from public.events);
