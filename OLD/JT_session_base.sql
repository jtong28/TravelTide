/* TravelTide – Session-level base table for EDA
   --------------------------------------------------------------------------
   Cohort definition (from the project brief):
    - Only sessions from 2023-01-04 onward (after the holiday period)
    - Only users with more than 7 sessions in that period, so every user has enough behavioral data for a reliable segmentation
   Grain of the output: one row = one session
   ========================================================================== */

WITH
  -- Step 1: Date filter applied once, so users and sessions always use the same cohort window.
  valid_sessions AS (
    SELECT *
    FROM sessions
    WHERE session_start >= '2023-01-04'  -- incl. January 4
  ),

  -- Step 2: Cohort users, counted only on sessions inside the window.
  valid_users AS (
    SELECT
      user_id,
      COUNT(*) AS session_count  -- kept for sanity checks (min. should be 8)
    FROM valid_sessions
    GROUP BY user_id             -- one row per user, so the join cannot duplicate sessions
    HAVING COUNT(*) > 7
  ),

  /* Step 3: session_base – reusable session-level table
     - Keeps full session detail before any aggregation.
     - The user-level CTE builds directly on it (GROUP BY user_id) without repeating filters or joins.
     - Separates data prep from metric calculation: easier debugging, consistent metrics.
     - A cancelled trip can appear in two sessions with the same trip_id, so the user level needs
       COUNT(DISTINCT trip_id) and explicit cancellation handling.
     - Explicit columns: each column appears once and its source table is clear. */
  session_base AS (
    SELECT
      -- Sessions
      vs.session_id,
      vs.user_id,
      vs.trip_id,
      vs.session_start,
      vs.session_end,
      vs.page_clicks,
      vs.flight_discount,
      vs.flight_discount_amount,
      vs.flight_booked,
      vs.hotel_discount,
      vs.hotel_discount_amount,
      vs.hotel_booked,
      vs.cancellation,

      -- Cohort helper
      vu.session_count,

      -- Users
      u.birthdate,
      u.gender,
      u.married,
      u.has_children,
      u.home_country,
      u.home_city,
      u.home_airport,
      u.home_airport_lat,
      u.home_airport_lon,
      u.sign_up_date,

      -- Flights (NULL if no flight)
      f.origin_airport,
      f.destination,
      f.destination_airport,
      f.seats,
      f.return_flight_booked,
      f.departure_time,
      f.return_time,
      f.checked_bags,
      f.trip_airline,
      f.destination_airport_lat,
      f.destination_airport_lon,
      f.base_fare_usd,

      -- Hotels (NULL if no hotel)
      h.hotel_name,
      h.nights,
      h.rooms,
      h.check_in_time,
      h.check_out_time,
      h.hotel_per_room_usd

    FROM valid_sessions vs
    INNER JOIN valid_users vu ON vs.user_id = vu.user_id  -- cohort users only
    INNER JOIN users u        ON vs.user_id = u.user_id   -- adds user details
    -- LEFT JOINs keep sessions without a flight/hotel; trip_id is unique in both tables, so no duplicate rows
    LEFT JOIN flights f       ON vs.trip_id = f.trip_id
    LEFT JOIN hotels h        ON vs.trip_id = h.trip_id
  )

-- Next step: the user-level CTE goes between session_base and this SELECT.
SELECT *
FROM session_base;
