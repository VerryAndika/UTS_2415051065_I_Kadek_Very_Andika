-- BookFinder - skema database Supabase (PostgreSQL)
-- Project UTS Pemrograman Mobile - 2415051065 I Kadek Very Andika
-- Jalankan di Supabase Dashboard > SQL Editor.

create table if not exists public.saved_books (
  id           bigint generated always as identity primary key,
  student_id   text        not null default '2415051065',
  book_key     text        not null,                 -- key work Open Library, mis. /works/OL45804W
  title        text        not null check (char_length(trim(title)) > 0),
  author       text        not null default 'Unknown',
  cover_url    text,
  status       text        not null default 'want'
                 check (status in ('want', 'reading', 'done')),
  rating       int         check (rating between 1 and 5),
  note         text,
  current_page int         not null default 0 check (current_page >= 0),
  total_pages  int         check (total_pages > 0),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  constraint saved_books_unique_book unique (student_id, book_key),
  constraint saved_books_page_range
    check (total_pages is null or current_page <= total_pages)
);

-- Row Level Security aktif. Policy permisif untuk role anon HANYA untuk
-- keperluan praktikum (belum ada login). Aplikasi memakai publishable key,
-- bukan service_role key.
alter table public.saved_books enable row level security;

drop policy if exists "anon select saved_books" on public.saved_books;
drop policy if exists "anon insert saved_books" on public.saved_books;
drop policy if exists "anon update saved_books" on public.saved_books;
drop policy if exists "anon delete saved_books" on public.saved_books;

create policy "anon select saved_books" on public.saved_books
  for select to anon using (true);
create policy "anon insert saved_books" on public.saved_books
  for insert to anon with check (true);
create policy "anon update saved_books" on public.saved_books
  for update to anon using (true) with check (true);
create policy "anon delete saved_books" on public.saved_books
  for delete to anon using (true);

grant select, insert, update, delete on public.saved_books to anon;
