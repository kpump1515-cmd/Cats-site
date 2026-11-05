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

-- PAGE TEXT AND PHOTOS (every page in the menu, including Meet the Staff)
create table if not exists public.site_content (
  page text not null,
  key text not null,
  value text not null,
  updated_at timestamptz not null default now(),
  primary key (page, key)
);
alter table public.site_content enable row level security;
drop policy if exists "content public read" on public.site_content;
drop policy if exists "content staff write" on public.site_content;
create policy "content public read" on public.site_content for select to anon, authenticated using (true);
create policy "content staff write" on public.site_content for all to authenticated using (true) with check (true);

-- STAFF MEMBERS (Meet the Staff page)
create table if not exists public.staff_members (
  id bigint generated always as identity primary key,
  slug text unique not null,
  name text not null,
  title text,
  bio text,
  photo_url text,
  sort_order int not null default 100,
  created_at timestamptz not null default now()
);
alter table public.staff_members enable row level security;
drop policy if exists "staff public read" on public.staff_members;
drop policy if exists "staff staff write" on public.staff_members;
create policy "staff public read" on public.staff_members for select to anon, authenticated using (true);
create policy "staff staff write" on public.staff_members for all to authenticated using (true) with check (true);
insert into public.staff_members (slug, name, title, bio, photo_url, sort_order)
select * from (values
  ('tiffany-salter','Tiffany Salter','Executive Director / CEO','Serves as the top-ranking staff leader, managing daily operations, acting as the public spokesperson, and working closely with the board.','images/tiffany.jpg',1),
  ('arianna-salter','Arianna Salter','Director of Development','Leads the revenue-generation strategy, overseeing all fundraising, donor relations, and financial growth initiatives.','images/arianna.jpg',2),
  ('dondre-smiley','Dondre Smiley','Media Specialist','Creates and manages all media, including video and photos.','images/dondre.jpg',3),
  ('rikiyah-fowler','Rikiyah Fowler','Volunteer Coordinator','Finds and interviews new volunteers and matches them to specific skills and availability for the right tasks or roles.','images/rikiyah.jpg',4)
) v(slug,name,title,bio,photo_url,sort_order)
where not exists (select 1 from public.staff_members);
