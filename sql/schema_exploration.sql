-- STEP 1: Show all table names
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- STEP 2: View column names for 'flights'
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'flights'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- STEP 3: View column names for 'hotels'
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'hotels'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- STEP 4: View column names for 'sessions'
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'sessions'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- STEP 5: View column names for 'users'
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'users'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- STEP 6: View row counts of all tables
SELECT
    (SELECT COUNT(*) FROM flights) AS flights_rows,
    (SELECT COUNT(*) FROM hotels) AS hotels_rows,
    (SELECT COUNT(*) FROM sessions) AS sessions_rows,
    (SELECT COUNT(*) FROM users) AS users_rows;