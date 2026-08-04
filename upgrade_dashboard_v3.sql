begin;

alter table public.training_sessions
  add column if not exists record_percent numeric(6,3);

alter table public.training_sessions
  add column if not exists daily_session_no integer;

alter table public.training_sessions
  drop constraint if exists training_sessions_record_percent_check;

alter table public.training_sessions
  add constraint training_sessions_record_percent_check
  check (record_percent is null or (record_percent >= 0 and record_percent <= 200));

alter table public.training_sessions
  drop constraint if exists training_sessions_daily_session_no_check;

alter table public.training_sessions
  add constraint training_sessions_daily_session_no_check
  check (daily_session_no is null or daily_session_no > 0);

create unique index if not exists training_sessions_user_date_no_unique
on public.training_sessions(user_id, session_date, daily_session_no)
where daily_session_no is not null;

-- 2026-08-04 三次正式 Rhein-Main 长距离训练
update public.training_sessions
set daily_session_no = 1
where external_id = 'coach-20260804-rheinmain-15laps';

update public.training_sessions
set daily_session_no = 2,
    record_percent = 90.000
where external_id = 'coach-20260804-rheinmain-16laps';

update public.training_sessions
set daily_session_no = 3,
    record_percent = 88.380
where external_id = 'coach-20260804-rheinmain-10laps';

-- 早期约38.3秒基准只作为估算背景，不计入正式长距离训练次数。
update public.training_sessions
set record_percent = 87.397
where external_id = 'coach-20260804-rheinmain-baseline';

commit;

select
  case
    when daily_session_no is not null
      then session_date::text || '-' || daily_session_no::text
    else session_date::text
  end as training_code,
  track,
  class_name,
  lap_count,
  best_lap,
  average_lap,
  record_percent
from public.training_sessions
order by session_date, daily_session_no nulls last, created_at;
