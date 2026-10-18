/* TravelTide – Session-level and user-level base tables
   --------------------------------------------------------------------------
   Cohort definition (from the project brief):
    - Only sessions from 2023-01-04 onward (after the holiday period)
    - Only users with more than 7 sessions in that period, so every user has enough behavioral data for a reliable segmentation
   Outputs (run one final SELECT at a time):
    - session_base : one row = one session  (49,211 rows)
    - user_base    : one row = one user     (5,998 rows)
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
  ),

  /* Step 4: Reference date = last session end in the cohort window (2023-07-28).
     Used for age and account tenure instead of CURRENT_DATE, so results don't change over time. */
  ref AS (
    SELECT MAX(session_end)::date AS ref_date
    FROM session_base
  ),

  -- Step 5: Trips that were cancelled (the cancellation session repeats the original trip_id).
  cancelled_trips AS (
    SELECT DISTINCT trip_id
    FROM session_base
    WHERE cancellation
  ),

  /* Step 6: valid_trips – one row per booked, NOT cancelled trip, with trip-level metrics.
     Only the booking session of a trip is kept (cancellation = FALSE), so each trip counts once. */
  valid_trips AS (
    SELECT
      sb.user_id,
      sb.trip_id,
      sb.destination,
      -- trip city: flight destination, or the city part of hotel_name ("Brand - city") for hotel-only trips,
      -- which have no flight destination; spaces are cleaned first because some names contain double spaces
      COALESCE(LOWER(TRIM(sb.destination)),
               LOWER(TRIM(SPLIT_PART(REGEXP_REPLACE(sb.hotel_name, '\s+', ' ', 'g'), ' - ', 2)))) AS trip_city,
      sb.flight_booked,
      sb.hotel_booked,
      sb.seats,
      sb.rooms,
      sb.checked_bags,
      sb.base_fare_usd,
      sb.hotel_per_room_usd,
      -- calendar nights from dates (raw "nights" counts 24-hour periods and has negative values);
      -- 0 or negative = invalid hotel dates -> NULL, so they don't pull averages down
      CASE WHEN sb.check_out_time::date - sb.check_in_time::date > 0
           THEN sb.check_out_time::date - sb.check_in_time::date END AS nights_calc,
      -- trip start = earlier of flight departure and hotel check-in
      LEAST(sb.departure_time, sb.check_in_time) AS trip_start,
      -- discount on the trip (flight or hotel)
      (COALESCE(sb.flight_discount, FALSE) OR COALESCE(sb.hotel_discount, FALSE)) AS any_discount,
      -- spend after discount
        COALESCE(sb.base_fare_usd, 0) * (1 - COALESCE(sb.flight_discount_amount, 0))
      + COALESCE(sb.hotel_per_room_usd, 0) * COALESCE(sb.rooms, 0)
        * GREATEST(COALESCE(sb.check_out_time::date - sb.check_in_time::date, 0), 0)  -- invalid dates -> 0 hotel cost
        * (1 - COALESCE(sb.hotel_discount_amount, 0))                          AS trip_spend_usd,
      -- haversine distance home airport -> destination airport in km (flights only)
      CASE WHEN sb.flight_booked THEN
        2 * 6371 * ASIN(SQRT(
            POWER(SIN(RADIANS(sb.destination_airport_lat - sb.home_airport_lat) / 2), 2)
          + COS(RADIANS(sb.home_airport_lat)) * COS(RADIANS(sb.destination_airport_lat))
          * POWER(SIN(RADIANS(sb.destination_airport_lon - sb.home_airport_lon) / 2), 2)))
      END AS distance_km
    FROM session_base sb
    WHERE sb.trip_id IS NOT NULL
      AND NOT sb.cancellation
      AND sb.trip_id NOT IN (SELECT trip_id FROM cancelled_trips)
  ),

  -- Step 7: Trip metrics per user (users without valid trips get NULLs → handled in user_base).
  trip_agg AS (
    SELECT
      user_id,
      COUNT(DISTINCT trip_id)                                                    AS valid_trips,
      SUM(CASE WHEN flight_booked THEN 1 ELSE 0 END)                             AS flights,
      SUM(CASE WHEN hotel_booked  THEN 1 ELSE 0 END)                             AS hotels,
      AVG(CASE WHEN flight_booked AND hotel_booked THEN 1.0 ELSE 0 END)          AS combo_share,
      AVG(CASE WHEN flight_booked AND NOT hotel_booked THEN 1.0 ELSE 0 END)      AS flight_only_share,
      AVG(CASE WHEN hotel_booked AND NOT flight_booked THEN 1.0 ELSE 0 END)      AS hotel_only_share,
      AVG(seats)                                                                 AS avg_seats,
      AVG(rooms)                                                                 AS avg_rooms,
      AVG(checked_bags)                                                          AS avg_bags,
      AVG(CASE WHEN hotel_booked THEN nights_calc END)                           AS avg_nights,
      AVG(distance_km)                                                           AS avg_distance_km,
      AVG(CASE WHEN EXTRACT(DOW FROM trip_start) IN (5, 6) THEN 1.0 ELSE 0 END)  AS weekend_start_share,  -- Fri/Sat
      AVG(CASE WHEN any_discount THEN 1.0 ELSE 0 END)                            AS discount_share,
      SUM(trip_spend_usd)                                                        AS total_spend_usd,
      AVG(trip_spend_usd)                                                        AS avg_spend_per_trip_usd
    FROM valid_trips
    GROUP BY user_id
  ),

  -- Step 8: Most visits to one city per user (for Favourite-City Returners), incl. hotel-only trips.
  dest_repeat AS (
    SELECT user_id, MAX(visits) AS max_visits_same_city
    FROM (
      SELECT user_id, trip_city, COUNT(*) AS visits
      FROM valid_trips
      WHERE trip_city IS NOT NULL
      GROUP BY user_id, trip_city
    ) d
    GROUP BY user_id
  ),

  -- Step 9: Session metrics per user (all sessions, incl. browsing-only).
  session_agg AS (
    SELECT
      user_id,
      MAX(session_count)                                                       AS session_count,
      AVG(EXTRACT(EPOCH FROM (session_end - session_start)) / 60)              AS avg_session_min,
      AVG(page_clicks)                                                         AS avg_page_clicks,
      COUNT(DISTINCT CASE WHEN cancellation THEN trip_id END)                  AS cancelled_trips
    FROM session_base
    GROUP BY user_id
  ),

  /* Step 10: user_base – one row per cohort user: demographics + session + trip metrics.
     Users with no valid trip ("Dreamers") get 0 trips instead of NULL. */
  user_base AS (
    SELECT
      u.user_id,
      -- Demographics
      DATE_PART('year', AGE(r.ref_date, u.birthdate))                          AS age,           -- exact age on 2023-07-28
      u.gender,
      u.married,
      u.has_children,
      u.home_country,
      u.home_city,
      u.home_airport,
      (r.ref_date - u.sign_up_date::date) / 30                                 AS tenure_months,
      -- Sessions
      sa.session_count,
      ROUND(sa.avg_session_min::numeric, 2)                                    AS avg_session_min,
      ROUND(sa.avg_page_clicks::numeric, 2)                                    AS avg_page_clicks,
      sa.cancelled_trips,
      -- Trips (0 for users who never kept a booking)
      COALESCE(ta.valid_trips, 0)                                              AS valid_trips,
      COALESCE(ta.flights, 0)                                                  AS flights,
      COALESCE(ta.hotels, 0)                                                   AS hotels,
      ROUND(ta.combo_share::numeric, 2)                                        AS combo_share,
      ROUND(ta.flight_only_share::numeric, 2)                                  AS flight_only_share,
      ROUND(ta.hotel_only_share::numeric, 2)                                   AS hotel_only_share,
      ROUND(ta.avg_seats::numeric, 2)                                          AS avg_seats,
      ROUND(ta.avg_rooms::numeric, 2)                                          AS avg_rooms,
      ROUND(ta.avg_bags::numeric, 2)                                           AS avg_bags,
      ROUND(ta.avg_nights::numeric, 2)                                         AS avg_nights,
      ROUND(ta.avg_distance_km::numeric, 0)                                    AS avg_distance_km,
      ROUND(ta.weekend_start_share::numeric, 2)                                AS weekend_start_share,
      ROUND(ta.discount_share::numeric, 2)                                     AS discount_share,
      ROUND(ta.total_spend_usd::numeric, 2)                                    AS total_spend_usd,
      ROUND(ta.avg_spend_per_trip_usd::numeric, 2)                             AS avg_spend_per_trip_usd,
      COALESCE(dr.max_visits_same_city, 0)                                     AS max_visits_same_city
    FROM users u
    INNER JOIN session_agg sa ON u.user_id = sa.user_id   -- cohort users only
    CROSS JOIN ref r
    LEFT JOIN trip_agg ta     ON u.user_id = ta.user_id   -- keeps users without valid trips
    LEFT JOIN dest_repeat dr  ON u.user_id = dr.user_id
  )

-- Choose ONE desired output and export it:
-- SELECT * FROM session_base;            -- gives us session data csv for 49,211 rows
SELECT * FROM user_base ORDER BY user_id; -- gives us user data csv for 5,998 rows
