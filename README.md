# ✈️ TravelTide: Personalized Rewards Program & Customer Segmentation Analysis

MSIT Mastery Project: customer segmentation of TravelTide booking data to design a personalized rewards program. Rule-based segments validated with K-Means, DBSCAN and PCA (silhouette-checked), plus new pilot perks. Built with SQL, Python (Pandas, Seaborn, scikit-learn) and Tableau.


## Mastery Project — Data Analytics

### 🎯 Project Overview
The objective of this project is to support TravelTide's Head of Marketing in designing a personalized rewards program that boosts customer engagement and long-term retention. 

Using a relational database spanning customer profiles, session logs, flight bookings, and hotel reservations, I analyze travel behaviors, booking patterns, and discount sensitivity. As the Data Analyst on this initiative, my goal is to translate exploratory findings into actionable recommendations that align perk personalization with distinct customer preferences.

## 📁 Repository Structure
```
TravelTide/
├── data/                              # SQL exports (CSV) + files written by the notebooks
│   ├── flights.csv                    # flights of the cohort, exported with sql/filtered_tables.sql (early exploration, not read by the notebooks)
│   ├── hotels.csv                     # hotel stays of the cohort, exported with sql/filtered_tables.sql (early exploration, not read by the notebooks)
│   ├── session_level_table.csv        # one row per session (SQL session_base)
│   ├── user_level_table.csv           # one row per user (SQL user_base)
│   ├── sessions_clean.csv             # cleaned session table, written by notebook 01
│   ├── users_features.csv             # user table + behavioral features, written by notebook 02
│   ├── users_segments.csv             # all features + segment, perks, K-Means and DBSCAN cluster, written by notebook 03
│   ├── user_perks.csv                 # final deliverable: one perk per customer (user_id, segment, perk, perk_source, pilot_perk)
│   ├── habit_or_luck.csv              # habit-or-luck test: each segment rule vs. 50 random shuffles, written by notebook 03 (used in Tableau)
│   ├── chance_models.csv              # Tableau helper: Dreamers vs. a chance model (notebook 03, section 3)
│   ├── persona_facts.csv              # Tableau helper: 4 facts per persona (notebook 03, section 8)
│   ├── perk_plan.csv                  # Tableau helper: launch / test plan per perk, with who, why and test design
│   └── perk_kpis.csv                  # Tableau helper: KPI to watch + today's baselines per perk
├── notebooks/
│   ├── 01_EDA_Cleaning.ipynb          # data cleaning & exploratory data analysis
│   ├── 02_User_Features.ipynb         # user-level features and their distributions
│   └── 03_Segments_Models.ipynb       # rule-based segments, habit-or-luck test, perks, K-Means, DBSCAN, PCA, personas
├── sql/
│   ├── schema_exploration.sql         # first look at the database: tables, columns and data types (basis for the ERD)
│   ├── filtered_tables.sql            # the four main tables (users, sessions, flights, hotels) filtered to the cohort (sessions from Jan 4, 2023, users with more than 7 sessions) – source of data/flights.csv and data/hotels.csv
│   └── session_and_user_base.sql      # cohort filter, session- and user-level tables (used by notebook 01)
├── images/
│   └── TravelTide_ERD.png             # database schema
├── TravelTide Rewards_JT.twbx         # Tableau workbook (story for the presentation, also on Tableau Public)
├── data_dictionary.md                 # every column of every CSV, with notes
├── .env.example                       # template for the optional database connection
├── requirements.txt
└── README.md
```

## ▶️ How to Run
1. Clone the repository and install the packages (Python 3.10+):
   ```bash
   python -m venv venv
   venv\Scripts\activate          # macOS / Linux: source venv/bin/activate
   pip install -r requirements.txt
   ```
2. Open the notebooks in `notebooks/` and run them **in order (01 → 02 → 03)** – each one writes the CSV the next one reads.
   - **With a database connection** (step 3): notebook 01 runs `sql/session_and_user_base.sql` itself and saves the two base tables in `data/` – no ready-made CSV is used.
   - **Without a connection**, the notebooks use the CSV export instead – no database needed:
     - The CSV files are read from `data/` (repo root or one level up from `notebooks/`).
     - If a file is missing, the notebook reads it from the project's Google Drive backup instead (shared as "anyone with the link"), so it also runs in Google Colab.
   - Notebook 01 installs its extra packages (e.g. `airports-py`) automatically if they are missing.
   - Notebook 03 writes the three final files: `users_segments.csv`, `user_perks.csv` and `habit_or_luck.csv`.
   - The four small Tableau helper tables (`chance_models.csv`, `persona_facts.csv`, `perk_plan.csv`, `perk_kpis.csv`) hold summary numbers and short texts taken from notebook 03 results for the Tableau story; they are not written by a notebook.
3. *Optional – database connection:* copy `.env.example` to `.env` and insert the course database URL (in Colab: a secret named `TRAVELTIDE_URL`). Notebook 01 then builds its two input tables from the database (section 1.1; set `BUILD_FROM_DATABASE = False` to use the CSVs instead). For the extra live check in section 1.2 (e.g. the gender split before the cohort filter), set `RUN_LIVE_QUERIES = True`. The `.env` file is listed in `.gitignore`, so the URL is never committed.

> **Opening the CSVs in Excel with German settings:** Excel reads decimals like `1.5` as dates (1 May). Use *Daten → Text in Spalten → Weitere…* and set the decimal separator to `.` – the files themselves are correct. In Tableau, set *Text File Properties → Locale* to **English (United States)** for the same reason.
