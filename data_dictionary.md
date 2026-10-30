# TravelTide – Data Dictionary

All tables cover Elena's cohort: sessions from **2023-01-04** onward, users with **more than 7 sessions** in that window (49,211 sessions, 5,998 users). Reference date for age and tenure: **2023-07-28** (last session end in the data).

| File | Grain | Rows | Created by |
|---|---|---:|---|
| `data/session_level_table.csv` | one row per browsing session | 49,211 | SQL `session_base` (`sql/session_and_user_base.sql`) |
| `data/sessions_clean.csv` | one row per browsing session | 49,211 | notebook 01 (cleaned + derived columns) |
| `data/user_level_table.csv` | one row per user | 5,998 | SQL `user_base` (`sql/session_and_user_base.sql`) |
| `data/users_features.csv` | one row per user | 5,998 | notebook 02 (user table formatted + extra features) |
| `data/users_segments.csv` | one row per user | 5,998 | notebook 03 (features + segment, perk, K-Means and DBSCAN cluster) |
| `data/user_perks.csv` | one row per user | 5,998 | notebook 03 – **final deliverable**: `user_id`, `segment`, `perk`, `perk_source`, `pilot_perk` |
| `data/habit_or_luck.csv` | one row per tested rule | 10 | notebook 03, section 3 – habit-or-luck test, used for the Tableau story |
| `data/chance_models.csv`, `persona_facts.csv`, `perk_plan.csv`, `perk_kpis.csv` | small Tableau helper tables | 4 / 36 / 6 / 18 | summary numbers and texts from notebook 03 results (section 7 below) |

**Missing values are structural, not errors:** flight columns are empty when no flight was booked, hotel columns when no hotel was booked, trip columns for browsing-only sessions (see notebook 01, section 3.4). They are never filled with 0.

---

## 1. Session-level table (`session_level_table.csv`)
Raw SQL export – the four Postgres tables joined on `user_id` and `trip_id`.

### From `sessions`
| Column | Type | Description | Notes |
|---|---|---|---|
| `session_id` | text | Unique ID of a browsing session | primary key |
| `user_id` | int | User who started the session | key to `users` |
| `trip_id` | text | Trip booked (or canceled) in this session | empty for browsing-only sessions; a cancellation session repeats the trip_id of the original booking |
| `session_start`, `session_end` | timestamp | Start and end of the session | |
| `page_clicks` | int | Clicks during the session | cancellation sessions are capped at 200 |
| `flight_discount`, `hotel_discount` | bool | A flight / hotel discount was **offered** in the session | offered ≠ used – see `discount_used` |
| `flight_discount_amount`, `hotel_discount_amount` | numeric | Discount as a share of the price (0.10 = 10 %) | empty when no discount was offered |
| `flight_booked`, `hotel_booked` | bool | A flight / hotel was booked in the session | repeated on cancellation sessions |
| `cancellation` | bool | The session canceled an earlier booking | 610 sessions = 610 canceled trips |

### SQL helper
| Column | Type | Description | Notes |
|---|---|---|---|
| `session_count` | int | Number of sessions of the user in the cohort window | used for the "more than 7 sessions" rule (min. 8) |

### From `users`
| Column | Type | Description | Notes |
|---|---|---|---|
| `birthdate` | date | Date of birth | replaced by `age` in the clean table |
| `gender` | text | `F` / `M` / `O` | 88 % F in the cohort, but only 44 % across all users – not used for perks |
| `married`, `has_children` | bool | Marital status, children in the household | |
| `home_country` | text | `usa` / `canada` | formatted `USA` / `Canada` |
| `home_city` | text | Home city | three names stand for two cities each (Portland, Jacksonville, Fayetteville) – use with `home_airport` |
| `home_airport` | text | IATA code assigned to the home city | 27 % are not large scheduled airports (e.g. military bases) |
| `home_airport_lat`, `home_airport_lon` | numeric | Coordinates of the home airport | used for distance and maps |
| `sign_up_date` | date | Account creation date | replaced by `tenure_months` in the clean table |

### From `flights` (empty when no flight was booked)
| Column | Type | Description | Notes |
|---|---|---|---|
| `origin_airport` | text | Departure airport | equals `home_airport` for 99.7 % of flights |
| `destination` | text | Destination city | |
| `destination_airport` | text | Destination IATA code | |
| `destination_airport_lat`, `destination_airport_lon` | numeric | Coordinates of the destination airport | |
| `seats` | int | Seats booked | party size; r = 0.98 with `rooms` |
| `return_flight_booked` | bool | Return flight included | False = one-way (618 flights) |
| `departure_time`, `return_time` | timestamp | Outbound / return flight | return = departure + whole days; 70 flight-only trips have identical timestamps (data artifact, kept) |
| `checked_bags` | int | Checked bags | |
| `trip_airline` | text | Airline | 2 names repaired after import (non-UTF-8) |
| `base_fare_usd` | numeric | Fare for **all seats** before discount (USD) | ≈ $0.18 per km and seat for return flights, half for one-way |

### From `hotels` (empty when no hotel was booked)
| Column | Type | Description | Notes |
|---|---|---|---|
| `hotel_name` | text | `"Brand - City"` | 957 hotels from 20 chains; brand **and** city are kept |
| `nights` | int | Raw nights | counts full 24-hour periods, has negative values → replaced by `nights_calc` |
| `rooms` | int | Rooms booked | |
| `check_in_time`, `check_out_time` | timestamp | Hotel stay | |
| `hotel_per_room_usd` | numeric | Price per room and night before discount (USD) | |

---

## 2. Cleaned session table (`sessions_clean.csv`)
Same 49,211 rows. Text formatted (Title Case, upper-case airport codes, `USA` / `Canada`); `birthdate`, `sign_up_date` and raw `nights` replaced. Additional columns:

| Column | Type | Description | Notes |
|---|---|---|---|
| `hotel_city` | text | City part of `hotel_name` | the only location of hotel-only trips |
| `home_airport_name`, `destination_airport_name` | text | Full airport names (package `airports-py`) | 2 closed Berlin airports added by hand |
| `nights_calc` | int | Calendar nights = check-out date − check-in date | empty for 0 or negative nights |
| `invalid_hotel_dates` | bool | Hotel booked with check-out on or before check-in | 2.9 % of hotel sessions |
| `trip_cancelled` | bool | The session's trip was canceled at some point | |
| `valid_booking` | bool | Booking session whose trip was never canceled | 15,489 valid bookings – **use this to analyze travel behavior** |
| `age` | int | Exact age in years on 2023-07-28 | |
| `tenure_months` | float | Months since sign-up on 2023-07-28 (days / 30.44) | |
| `is_minor` | bool | Under 18 on 2023-07-28 | 246 users – kept, flagged |
| `session_minutes` | float | Session length in minutes | |
| `booking_type` | text | `browsing` / `flight + hotel` / `flight only` / `hotel only` / `cancellation` | |
| `trip_start` | timestamp | Earlier of departure and check-in | |
| `start_weekday` | text | Weekday of `trip_start` | |
| `weekend_start` | bool | Trip starts on Friday or Saturday | |
| `lead_days` | int | Days from booking session to trip start | flat signal (median 8) – not used for segmentation |
| `trip_city` | text | Flight destination, or hotel city for hotel-only trips | basis for repeat-city visits |
| `distance_km` | float | Great-circle (haversine) distance home airport → destination airport | same formula as in the SQL |
| `discount_used` | bool | Discount on the **booked** part of a valid booking (flight discount on a booked flight, hotel discount on a booked hotel) | empty for non-bookings; the session flags also show offers on the part *not* booked (549 valid bookings) – those don't count (notebook 01, 4.1) |
| `trip_spend_usd` | float | Fare + hotel cost after discounts | empty for non-bookings and for the 421 bookings with invalid hotel dates (hotel cost unknown) |

---

## 3. User-level table (`user_level_table.csv`)
One row per cohort user (5,998). Trip metrics use **valid bookings only** (canceled trips excluded). Users without a valid trip ("Dreamers", 556) have 0 trips and empty averages.

| Column | Type | Description | Notes |
|---|---|---|---|
| `user_id` | int | User ID | primary key |
| `age` | int | Exact age on 2023-07-28 | |
| `gender`, `married`, `has_children`, `home_country`, `home_city`, `home_airport` | – | Demographics, as in the session table | raw text formatting; formatted in notebook 01, section 4.2 |
| `tenure_months` | int | Months since sign-up (days / 30) | ⚠️ integer division in Postgres → whole months; the notebook's `tenure_months` uses days / 30.44 with decimals |
| `session_count` | int | Sessions in the cohort window | ≥ 8 by definition |
| `avg_session_min` | numeric | Average session length (minutes) | |
| `avg_page_clicks` | numeric | Average clicks per session | |
| `cancelled_trips` | int | Number of canceled trips | |
| `valid_trips` | int | Number of kept (not canceled) trips | 0 = Dreamer |
| `flights`, `hotels` | int | Valid trips with a flight / with a hotel | |
| `combo_share`, `flight_only_share`, `hotel_only_share` | numeric | Share of valid trips that are flight + hotel / flight only / hotel only | sum to 1 |
| `avg_seats`, `avg_rooms`, `avg_bags` | numeric | Average party size and luggage per trip | |
| `avg_nights` | numeric | Average calendar nights per hotel stay | invalid hotel dates excluded |
| `avg_distance_km` | numeric | Average flight distance (km) | |
| `weekend_start_share` | numeric | Share of trips starting Friday or Saturday | |
| `discount_share` | numeric | Share of valid trips with a discount on the booked part | same definition as `discount_used` (SQL `any_discount`) |
| `total_spend_usd`, `avg_spend_per_trip_usd` | numeric | Spend after discounts | empty for Dreamers (not applicable) and 26 users whose only trips had invalid hotel dates (unknown) – 582 users in total |
| `max_visits_same_city` | int | Most valid trips to one city (`trip_city`) | ≥ 2 for 805 users → Favorite-City Returners |

---

## 4. User features (`users_features.csv`)
All columns of the user-level table (section 3, text formatted as in notebook 01), plus:

| Column | Type | Description | Notes |
|---|---|---|---|
| `family_status` | text | `Married, children` / `Married, no children` / `Single, children` / `Single, no children` | from `married` × `has_children`; describes segments, not used in the rules |
| `party_size` | float | Larger of `avg_seats` and `avg_rooms` | seats and rooms r = 0.98 → one feature; ≥ 1.5 = Family Crew / Couples & Friends |
| `is_dreamer` | bool | No valid trip | 556 users |
| `repeat_city` | bool | `max_visits_same_city` ≥ 2 | 805 users |
| `cancel_rate` | float | canceled trips ÷ (valid + canceled trips) | empty for users who never booked |
| `avg_discount_pct` | float | Average discount on discounted valid bookings, in % – only discounts on the booked part (larger one if both were used) | how *big* the discount is (`discount_share` = how *often*); empty if no discount was used |
| `long_haul_share` | float | Share of valid flights over 3,000 km | empty for users without a valid flight; r = 0.7 with `avg_distance_km` |

Empty values mean "not applicable" (e.g. no flight → no bags, no distance) and are never filled with 0.

## 5. User segments (`users_segments.csv`)
All columns of `users_features.csv`, plus:

| Column | Type | Description | Notes |
|---|---|---|---|
| `segment` | text | Rule-based segment, first matching rule in priority order: Dreamers, Family Crew, Couples & Friends, Hotel Stayers, Favorite-City Returners, Deal Hunters, Long-haul Travelers, Package Travelers | rules: notebook 03, section 2; users matching no rule = `All-rounders` |
| `core_perk` | text | Core perk of the segment (Elena's five + extra-legroom seat for Long-haul Travelers) | notebook 03, section 4; All-rounders: "assigned by perk score" |
| `perk` | text | **Final perk** of the customer: the segment's core perk, or for All-rounders the perk with the highest perk score | notebook 03, 4.1 |
| `perk_source` | text | `segment rule` or `perk score` | |
| `pilot_perk` | text | New perk to A/B test for the segment (e.g. 48-h Fare Lock for Dreamers) | empty for All-rounders |
| `kmeans_cluster` | int | K-Means cluster (k = 8) on 9 standardized behavioral features | bookers only – empty for Dreamers; used to check the rules, not to assign perks |
| `dbscan_cluster` | int | DBSCAN cluster (ε = 1.5, MinPts = 18) on the same 9 features; −1 = noise (outlier) | bookers only – empty for Dreamers; used as a second check, not to assign perks |

## 6. Habit or luck (`habit_or_luck.csv`)
One row per tested rule (10 rows). Each rule from the segment definitions is counted in the real data and in 50 versions where the valid trips were dealt out to the users again at random (every user keeps their number of trips). A rule is a **habit** when the real count is above what 95 % of the shuffles give.

| Column | Type | Description | Notes |
|---|---|---|---|
| `rule` | text | The rule that was tested, e.g. `Hotel Stayers: hotel-only ≥ 50 %` | rows starting with spaces (`   core: …`) are a stricter part of the rule above |
| `real` | int | Users who meet the rule in the real data | |
| `luck_avg` | float | Average count over the 50 shuffles | what luck alone gives |
| `luck_low`, `luck_high` | float | 5th and 95th percentile of the 50 shuffles | the luck range (middle 90 %) |
| `ratio` | float | `real` ÷ average luck count | 1.0 = exactly what luck gives; 1.26 = 26 % more users than luck |
| `verdict` | text | `luck` / `habit` / `strong habit` | `luck` if `real` ≤ `luck_high`; `strong habit` if also `ratio` ≥ 1.2; otherwise `habit` |

## 7. Tableau helper tables
Small tables for the Tableau story. They hold summary numbers and short texts taken from notebook 03 results and are not written by a notebook. In Tableau each one is its own data source (Text File Properties: UTF-8, locale English (United States)).

### `chance_models.csv` (story point 3, 4 rows)
| Column | Type | Description | Notes |
|---|---|---|---|
| `question` | text | `Customers who never book` or `Customers who book in at least half of their sessions` | notebook 03, section 3 |
| `kind` | text | `Real` or `By chance` | chance model: binomial, same booking rate for everyone |
| `customers` | int | Number of customers | never book: 458 real vs. 236 by chance · book in ≥ half: 1,598 vs. 1,382 |
| `sort` | int | 1 = Real, 2 = By chance | bar order in Tableau |

### `persona_facts.csv` (story point 4, 36 rows = 9 personas × 4 facts)
| Column | Type | Description | Notes |
|---|---|---|---|
| `segment` | text | Segment of the persona | matches `segment` in `users_segments.csv` |
| `tile_row`, `tile_col` | int | Position of the fact tile in the 2 × 2 grid | 1 or 2 |
| `fact` | text | Label, e.g. `Hotel-only` | the facts that best show the segment's habit |
| `value` | text | Formatted value, e.g. `50 %` | from the persona's row in `users_segments.csv` (notebook 03, section 8) |

### `perk_plan.csv` (story point 5, 6 rows = one per perk)
| Column | Type | Description | Notes |
|---|---|---|---|
| `perk` | text | Perk name | `Extra-legroom seat (new)` = the new perk |
| `perk_group` | text | `Launch now` (backed by a habit) or `Test first` (A/B test) | launch: 4,769 customers · test: 1,229 |
| `sort` | int | Order in the lists | |
| `customers` | int | Customers who get this perk | same counts as `user_perks.csv` |
| `short` | text | One-line reason shown under the perk | |
| `kicker` | text | Small heading of the detail card | |
| `who` | text | Segments that get the perk, with customer counts | |
| `why` | text | The evidence behind the decision | habit-or-luck test and notebook 03, sections 3–4 |
| `design` | text | Test design: 20 % control group (launch) or 50 / 50 split (test first) | group sizes and length are proposals |

### `perk_kpis.csv` (story point 5, 18 rows = 6 perks × 3 tiles)
| Column | Type | Description | Notes |
|---|---|---|---|
| `perk` | text | Perk name | matches `perk_plan.csv` |
| `tile` | int | 1 = KPI to watch, 2 and 3 = today's baselines | |
| `label` | text | Tile label, e.g. `Today · Trips per Hotel Stayer` | |
| `value` | text | Formatted value, e.g. `2.0` | baselines from `users_segments.csv` and `sessions_clean.csv` |
