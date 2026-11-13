-- Learning Library - skema database Supabase (PostgreSQL)
-- Project UTS Pemrograman Mobile - 2415051065 I Kadek Very Andika
-- Jalankan di Supabase Dashboard > SQL Editor.
--
-- Satu baris = satu Learning Item: apa pun yang ingin dipelajari
-- (buku, artikel, video, course, game, podcast, riset, lainnya).

create table if not exists public.learning_items (
  id              bigint generated always as identity primary key,
  student_id      text        not null default '2415051065',
  title           text        not null check (char_length(trim(title)) > 0),
  media_type      text        not null default 'book'
                    check (media_type in ('book','article','video','course','game','podcast','research','other')),
  topic           text        not null default 'Umum',     -- bidang pengetahuan, mis. Psychology
  creator         text,                                    -- penulis / channel / penerbit
  url             text,
  source          text        not null default 'Manual',   -- asal rekomendasi: TikTok, YouTube, Teman, ...
  description     text,                                    -- isi singkat item
  characteristics text,                                    -- tag/karakteristik, dipisah koma
  reason          text,                                    -- mengapa disimpan
  status          text        not null default 'inbox'
                    check (status in ('inbox','want','progress','done')),
  notes           text,                                    -- catatan belajar / refleksi
  rating          int         check (rating between 1 and 5),
  cover_url       text,
  external_key    text,                                    -- key Open Library (jika dari Discover)
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists learning_items_student_idx
  on public.learning_items (student_id, created_at desc);

-- Row Level Security aktif. Policy permisif untuk role anon HANYA untuk
-- keperluan praktikum (belum ada login). Aplikasi memakai publishable key.
alter table public.learning_items enable row level security;

drop policy if exists "anon select learning_items" on public.learning_items;
drop policy if exists "anon insert learning_items" on public.learning_items;
drop policy if exists "anon update learning_items" on public.learning_items;
drop policy if exists "anon delete learning_items" on public.learning_items;

create policy "anon select learning_items" on public.learning_items
  for select to anon using (true);
create policy "anon insert learning_items" on public.learning_items
  for insert to anon with check (true);
create policy "anon update learning_items" on public.learning_items
  for update to anon using (true) with check (true);
create policy "anon delete learning_items" on public.learning_items
  for delete to anon using (true);

grant select, insert, update, delete on public.learning_items to anon;
