create table subjects (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 60)
);

create table grades (
  id bigint generated always as identity primary key,
  subject_id bigint not null references subjects(id) on delete cascade,
  value numeric not null check (value between 1 and 6),
  weight numeric not null default 1 check (weight > 0 and weight <= 100),
  title text not null default '' check (char_length(title) <= 80),
  date date not null default current_date
);

create index on grades (subject_id);

-- Jeder sieht und ändert nur seine eigenen Daten
alter table subjects enable row level security;
alter table grades enable row level security;

grant select, insert, update, delete on subjects, grades to authenticated;

create policy "eigene Faecher" on subjects
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy "eigene Noten" on grades
  for all to authenticated
  using (exists (select 1 from subjects s where s.id = grades.subject_id and s.user_id = (select auth.uid())))
  with check (exists (select 1 from subjects s where s.id = grades.subject_id and s.user_id = (select auth.uid())));
