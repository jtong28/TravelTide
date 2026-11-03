# ✈️ TravelTide: Personalized Rewards Program & Customer Segmentation Analysis

MSIT Mastery Project: customer segmentation of TravelTide booking data to design a personalized rewards program. Rule-based segments validated with K-Means, DBSCAN and PCA (silhouette-checked), plus new pilot perks. Built with SQL, Python (Pandas, Seaborn, scikit-learn) and Tableau.

## 🛠️ Tools & Skills Used

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=flat&logo=postgresql&logoColor=white) ![VS Code](https://img.shields.io/badge/VS_Code-007ACC?style=flat&logo=visualstudiocode&logoColor=white) ![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white) ![Jupyter](https://img.shields.io/badge/Jupyter-F37626?style=flat&logo=jupyter&logoColor=white) ![Pandas](https://img.shields.io/badge/Pandas-150458?style=flat&logo=pandas&logoColor=white) ![NumPy](https://img.shields.io/badge/NumPy-013243?style=flat&logo=numpy&logoColor=white) ![Matplotlib](https://img.shields.io/badge/Matplotlib-11557C?style=flat&logoColor=white) ![Seaborn](https://img.shields.io/badge/Seaborn-3776AB?style=flat&logoColor=white) ![Plotly](https://img.shields.io/badge/Plotly-3F4F75?style=flat&logo=plotly&logoColor=white) ![scikit-learn](https://img.shields.io/badge/scikit--learn-F7931E?style=flat&logo=scikitlearn&logoColor=white) ![SciPy](https://img.shields.io/badge/SciPy-8CAAE6?style=flat&logo=scipy&logoColor=white) ![SQLAlchemy](https://img.shields.io/badge/SQLAlchemy-D71F00?style=flat&logo=sqlalchemy&logoColor=white) ![Tableau](https://img.shields.io/badge/Tableau-E97627?style=flat&logo=tableau&logoColor=white) ![Git](https://img.shields.io/badge/Git-F05032?style=flat&logo=git&logoColor=white)

**Skills:** SQL (CTEs, left/inner joins, aggregations, haversine flight distance) · data cleaning and validation · feature engineering · rule-based segmentation · permutation test ("habit or luck") and a binomial chance model · K-Means, DBSCAN and PCA on standardized features (silhouette and Davies-Bouldin checks) · data storytelling in Tableau

## 🔗 Quick Access

- 📊 **Tableau Public story:** [View the interactive story](https://public.tableau.com/views/TravelTideRewards_JT/TravelTide?:language=en-US&:display_count=n&:origin=viz_share_link) – 5 points: customers & trips · nine groups · habit or luck · perks & personas · recommendation
- 💾 **Tableau workbook (offline copy):** [`TravelTide Rewards_JT.twbx`](TravelTide%20Rewards_JT.twbx) – the same story, opens in Tableau Desktop or the free Tableau Public app without internet
- 📋 **Executive Summary (1 page):** [`TravelTide_Rewards_Executive_Summary.pdf`](TravelTide_Rewards_Executive_Summary.pdf)
- 📄 **Detailed Report (3 pages):** [`TravelTide_Rewards_Detailed_Report.pdf`](TravelTide_Rewards_Detailed_Report.pdf)
- 📓 **Notebooks:** [01 Cleaning & EDA](notebooks/01_EDA_Cleaning.ipynb) · [02 User features](notebooks/02_User_Features.ipynb) · [03 Segments, models & perks](notebooks/03_Segments_Models.ipynb)
- ✅ **Final deliverable – one perk per customer:** [`data/user_perks.csv`](data/user_perks.csv)
- 🧾 **SQL:** [`sql/session_and_user_base.sql`](sql/session_and_user_base.sql) (cohort, session- and user-level tables)
- 📚 **Data dictionary:** [`data_dictionary.md`](data_dictionary.md)
- 🗺️ **Database schema (ERD):** [`images/TravelTide_ERD.png`](images/TravelTide_ERD.png)

---

## 📝 Project Description

The objective of this project is to support TravelTide's Head of Marketing in designing a personalized rewards program that boosts customer engagement and long-term retention.

Using a relational database spanning customer profiles, session logs, flight bookings, and hotel reservations, I analyze travel behaviors, booking patterns, and discount sensitivity. As the Data Analyst on this initiative, my goal is to translate exploratory findings into actionable recommendations that align perk personalization with distinct customer preferences.

**Goal:** keep customers engaged and booking again by offering each one the perk that matches how they actually travel. Marketing asked two questions:
1. **Does the data support the five proposed perks?** (free hotel meal, free checked bag, no cancellation fees, exclusive discounts, 1 night free hotel with flight)
2. **Which perk should each customer get,** so every invitation can lead with it?

---

## 📊 Project Summary

### Approach
- **Cohort:** 5,998 customers with more than 7 sessions since Jan 4, 2023 – 49,211 sessions and 15,489 trips that were not canceled (data up to Jul 28, 2023).
- **Data preparation:** canceled trips left out, hotel nights recalculated from the check-in/check-out dates, discounts counted only on the booked part of a trip.
- **Segmentation:** 8 transparent rules in a fixed priority order (most specific habit first) → 9 segments; customers who match no rule (All-rounders) get the perk they score highest on.
- **Habit or luck?** Every rule was checked against chance: all trips were shuffled between customers 50 times, and a rule only counts as a habit if the real data beats 95 % of the shuffles.
- **Machine-learning cross-check:** K-Means, DBSCAN and PCA – which never saw the rules – confirm the strongest groups (K-Means finds 4 of 7 booker segments on its own).

### Key insights
- **Three of the five perks rest on a real habit:** hotel-only stays (+26 % vs. luck → free hotel meal), always booking flight + hotel (+17 % → 1 night free hotel with flight), and customers with a single booking cancel it about 3× as often as chance (→ no cancellation fees).
- **Discounts and checked bags look like luck:** neither beats the shuffles, and sessions with a flight discount ended in a flight booking *less* often (23.8 % vs. 29.1 %).
- **Distance is a habit worth a new perk:** long-haul travelers fly far (+9 %) but don't check more bags → **extra-legroom seat** instead of a free bag.
- **Everyone is covered:** 76 % of customers get their perk from a segment rule, 24 % (All-rounders) from their perk scores.

### Recommendations
1. **Launch now** the four habit-backed perks (4,769 customers, 80 %).
2. **A/B-test first** exclusive discounts and the free checked bag (1,229 customers, 20 %).
3. **Pilot one new idea per segment** – e.g. a 48-hour fare lock for the Dreamers, who browse but never keep a booking.
4. **Measure** against a control group (rewards sign-ups, booking rate 33.1 %, trips per customer 2.6, cancellation rate 3.8 %) and **re-run the segmentation every quarter.**

### Links to files
All files are listed under [Quick Access](#-quick-access) at the top: executive summary, detailed report, Tableau story (online and offline), notebooks, the final perk list, SQL, data dictionary and ERD.

---

## ⚙️ Installation

Requires Python 3.10+. Clone the repository and install the packages from `requirements.txt` in a virtual environment:

```bash
git clone https://github.com/jtong28/TravelTide.git
cd TravelTide
python -m venv venv
venv\Scripts\activate          # macOS / Linux: source venv/bin/activate
pip install -r requirements.txt
```

---

## ▶️ Usage

1. Open the notebooks in `notebooks/` and run them **in order (01 → 02 → 03)** – each one writes the CSV the next one reads.
   - **Without a database connection** (default), the notebooks use the CSV exports in `data/`. If a file is missing, they read it from the project's Google Drive backup, so they also run in Google Colab.
   - Notebook 01 installs its extra packages (e.g. `airports-py`) automatically if they are missing.
   - Notebook 03 writes the final files: `users_segments.csv`, `user_perks.csv` and `habit_or_luck.csv`.
2. *Optional – database connection:* copy `.env.example` to `.env` and insert the course database URL (in Colab: a secret named `TRAVELTIDE_URL`). Notebook 01 then builds its two input tables straight from the database with `sql/session_and_user_base.sql`. The `.env` file is listed in `.gitignore`, so the URL is never committed.
3. *Tableau:* open [`TravelTide Rewards_JT.twbx`](TravelTide%20Rewards_JT.twbx) in Tableau Desktop or the free Tableau Public app (works offline), or use the [online story](https://public.tableau.com/views/TravelTideRewards_JT/TravelTide?:language=en-US&:display_count=n&:origin=viz_share_link).

> **Opening the CSVs in Excel with German settings:** Excel reads decimals like `1.5` as dates (1 May). Use *Daten → Text in Spalten → Weitere…* and set the decimal separator to `.` – the files themselves are correct. In Tableau, set *Text File Properties → Locale* to **English (United States)** for the same reason.

> **Plotly maps on GitHub:** GitHub's notebook preview doesn't show interactive Plotly charts – run the notebook (or open it in Colab) to see them.

---

## 💡 Example Usage

Look up which perk the program assigns – for all customers or for one:

```python
import pandas as pd

perks = pd.read_csv("data/user_perks.csv")

perks["perk"].value_counts()             # customers per perk
perks.loc[perks["user_id"] == 508497]    # one customer: segment, perk and pilot perk
```

Output:
```text
perk
No cancellation fees              1566
1 night free hotel with flight    1555
Free hotel meal                   1271
Exclusive discounts                723
Free checked bag                   506
Extra-legroom seat                 377
Name: count, dtype: int64

     user_id        segment             perk   perk_source                 pilot_perk
789   508497  Hotel Stayers  Free hotel meal  segment rule  Welcome dinner on night 1
```

Marketing can merge this file with the email list on `user_id`, so every invitation opens with the customer's own perk.

---

## 📁 Directory Structure
```
TravelTide/
├── data/                              # SQL exports (CSV) + files written by the notebooks
│   ├── flights.csv                    # cohort flights from sql/filtered_tables.sql (early exploration only)
│   ├── hotels.csv                     # cohort hotel stays from sql/filtered_tables.sql (early exploration only)
│   ├── session_level_table.csv        # one row per session (SQL session_base)
│   ├── user_level_table.csv           # one row per user (SQL user_base)
│   ├── sessions_clean.csv             # cleaned session table, written by notebook 01
│   ├── users_features.csv             # user table + behavioral features, written by notebook 02
│   ├── users_segments.csv             # features + segment, perks and clusters, written by notebook 03
│   ├── user_perks.csv                 # final deliverable: one perk per customer
│   ├── habit_or_luck.csv              # each segment rule vs. 50 random shuffles, written by notebook 03
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
│   ├── filtered_tables.sql            # the four main tables filtered to the cohort (source of flights.csv and hotels.csv)
│   └── session_and_user_base.sql      # cohort filter, session- and user-level tables (used by notebook 01)
├── images/
│   └── TravelTide_ERD.png             # database schema
├── TravelTide_Rewards_Executive_Summary.pdf   # one-page executive summary
├── TravelTide_Rewards_Detailed_Report.pdf     # detailed report (3 pages)
├── TravelTide Rewards_JT.twbx         # Tableau workbook: offline copy of the story (also on Tableau Public)
├── data_dictionary.md                 # every column of every CSV, with notes
├── .env.example                       # template for the optional database connection
├── .gitignore                         # keeps .env, virtual environments and temp files out of Git
├── requirements.txt
└── README.md
```

The four Tableau helper tables hold summary numbers and short texts from the notebook 03 results; they are not written by a notebook.

---

## 📦 Dependencies

All listed in `requirements.txt` and installed with `pip install -r requirements.txt` (see Installation):

| Package | Used for |
|---|---|
| pandas, numpy | data cleaning, features, segments |
| matplotlib, seaborn | charts in notebooks 01–03 |
| plotly, nbformat | interactive route and airport maps (notebook 01) |
| airports-py | full airport names |
| scikit-learn | K-Means, DBSCAN, PCA, silhouette score (notebook 03) |
| scipy | binomial chance model for the Dreamers (notebook 03, section 3) |
| sqlalchemy, psycopg2-binary, python-dotenv | *optional:* building the input tables straight from the PostgreSQL database |
