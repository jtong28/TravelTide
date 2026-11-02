-- session > 2023-01-04  mehr als 7 

-- users table
with valid_user as (
select
  user_id, count(*) as session_count
from
  sessions
where
  session_start >= '2023-01-04'
group by
  user_id
having
  count(session_id)>7)


select
  *
from
  users
where
  user_id in (select user_id from valid_user);
  

-- Sessions Table
with valid_user as (
select
  user_id, count(*) as session_count
from
  sessions
where
  session_start >= '2023-01-04'
group by
  user_id
having
  count(session_id)>7)


select
  *
from
  sessions
where
  user_id in (select user_id from valid_user) and session_start >= '2023-01-04';

-- hotels

with valid_user as (
select
  user_id, count(*) as session_count
from
  sessions
where
  session_start >= '2023-01-04'
group by
  user_id
having
  count(session_id)>7),

valid_sessions as (
select
  *
from
  sessions
where
  user_id in (select user_id from valid_user) and session_start >= '2023-01-04')


select
  *
from
  hotels
where
  trip_id in (select
  distinct trip_id
from valid_sessions);



-- flights
with valid_user as (
select
  user_id, count(*) as session_count
from
  sessions
where
  session_start >= '2023-01-04'
group by
  user_id
having
  count(session_id)>7),

valid_sessions as (
select
  *
from
  sessions
where
  user_id in (select user_id from valid_user) and session_start >= '2023-01-04')


select
  *
from
  flights
where
  trip_id in (select
  distinct trip_id
from valid_sessions)
