begin;

alter table public.training_sessions
  add column if not exists record_percent numeric(6,3);

alter table public.training_sessions
  drop constraint if exists training_sessions_record_percent_check;

alter table public.training_sessions
  add constraint training_sessions_record_percent_check
  check (record_percent is null or (record_percent >= 0 and record_percent <= 200));

-- 用户确认：Rhein-Main 1:8 Electric Buggy Spec，37.192 s 对应约 90% 赛道纪录。
update public.training_sessions
set record_percent = 90.000
where external_id = 'coach-20260804-rheinmain-16laps';

-- 下面两项按同一百分比尺度推算，用于趋势显示。
update public.training_sessions
set record_percent = 88.380
where external_id = 'coach-20260804-rheinmain-10laps';

update public.training_sessions
set record_percent = 87.397
where external_id = 'coach-20260804-rheinmain-baseline';

commit;

select
  session_date,
  track,
  class_name,
  best_lap,
  average_lap,
  record_percent
from public.training_sessions
order by created_at;
