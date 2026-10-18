WITH
  -- Filter sessions that started after 2023-01-04
  filtered_sessions AS (
    SELECT *
    FROM sessions
    WHERE session_start >= '2023-01-04'
    ),

  -- Identify users with more than 7 sessions
  filtered_users AS (
    SELECT
      user_id
      , COUNT(*) AS session_count
    FROM filtered_sessions
    GROUP BY user_id
    HAVING COUNT(*) > 7
    ),

  -- Join filtered sessions with users, flights, and hotels for identified users
  session_base AS (
    SELECT
      -- Columns from "sessions" table
      s.session_id
      , s.user_id
      , s.trip_id
      , s.session_start
      , s.session_end
      , s.page_clicks
      , s.flight_discount
      , s.flight_discount_amount
      , s.flight_booked
      , s.hotel_discount
      , s.hotel_discount_amount
      , s.hotel_booked
      , s.cancellation

      -- Columns from "users" table
      , u.birthdate
      , u.gender
      , u.married
      , u.has_children
      , u.home_country
      , u.home_city
      , u.home_airport
      , u.home_airport_lat
      , u.home_airport_lon
      , u.sign_up_date

      -- Columns from "flights" table
      , f.origin_airport
      , f.destination
      , f.destination_airport
      , f.seats
      , f.return_flight_booked
      , f.departure_time
      , f.return_time
      , f.checked_bags
      , f.trip_airline
      , f.destination_airport_lat
      , f.destination_airport_lon
      , f.base_fare_usd AS flight_base_fare_usd

      -- Columns from "hotels" table
      , h.hotel_name
      , h.nights
      , h.rooms
      , h.check_in_time
      , h.check_out_time
      , h.hotel_per_room_usd AS hotel_base_nightly_rate_usd

    FROM filtered_sessions s
    INNER JOIN users u USING (user_id)
    LEFT JOIN flights f USING (trip_id)
    LEFT JOIN hotels h USING (trip_id)
    WHERE s.user_id IN (
      SELECT user_id
      FROM filtered_users
      )
    )

SELECT *
FROM session_base;