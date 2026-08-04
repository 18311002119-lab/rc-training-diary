create extension if not exists pgcrypto;

create table if not exists public.training_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  external_id text,
  session_date date not null default current_date,
  daily_session_no integer check (daily_session_no is null or daily_session_no > 0),
  simulator text not null default 'VRC Pro',
  track text not null,
  class_name text not null,
  mode text not null default 'Practice',
  lap_count integer check (lap_count is null or lap_count > 0),
  best_lap numeric(8,3) check (best_lap is null or best_lap > 0),
  average_lap numeric(8,3) check (average_lap is null or average_lap > 0),
  median_lap numeric(8,3) check (median_lap is null or median_lap > 0),
  best5_average numeric(8,3) check (best5_average is null or best5_average > 0),
  record_percent numeric(6,3) check (record_percent is null or (record_percent >= 0 and record_percent <= 200)),
  mistake_count integer check (mistake_count is null or mistake_count >= 0),
  lap_times jsonb,
  focus text,
  notes text,
  coach_note text,
  next_goal text,
  vehicle_setup text,
  controller_setup text,
  mood integer check (mood is null or mood between 1 and 5),
  source text not null default 'user',
  approximate boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists training_sessions_user_external_unique
on public.training_sessions(user_id, external_id)
where external_id is not null;

create unique index if not exists training_sessions_user_date_no_unique
on public.training_sessions(user_id, session_date, daily_session_no)
where daily_session_no is not null;

alter table public.training_sessions enable row level security;

grant usage on schema public to authenticated;
grant select, insert, update, delete on table public.training_sessions to authenticated;

drop policy if exists "Users read own sessions" on public.training_sessions;
create policy "Users read own sessions"
on public.training_sessions for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users insert own sessions" on public.training_sessions;
create policy "Users insert own sessions"
on public.training_sessions for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Users update own sessions" on public.training_sessions;
create policy "Users update own sessions"
on public.training_sessions for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users delete own sessions" on public.training_sessions;
create policy "Users delete own sessions"
on public.training_sessions for delete
to authenticated
using ((select auth.uid()) = user_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists training_sessions_set_updated_at on public.training_sessions;
create trigger training_sessions_set_updated_at
before update on public.training_sessions
for each row execute function public.set_updated_at();
