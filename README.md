# ✈️ TravelTide: Personalized Rewards Program & Customer Segmentation Analysis

MSIT Mastery Project: customer segmentation of TravelTide booking data to design a personalized rewards program. Rule-based segments validated with K-Means and DBSCAN (silhouette-checked), plus new pilot perks. Built with SQL, Python (Pandas, Seaborn, scikit-learn), Tableau and Streamlit.


## Mastery Project — Data Analytics

### 🎯 Project Overview
The objective of this project is to support TravelTide's Head of Marketing in designing a personalized rewards program that boosts customer engagement and long-term retention. 

Using a relational database spanning customer profiles, session logs, flight bookings, and hotel reservations, I analyze travel behaviors, booking patterns, and discount sensitivity. As the Data Analyst on this initiative, my goal is to translate exploratory findings into actionable recommendations that align perk personalization with distinct customer preferences.

## 📁 Repository Structure
```
TravelTide/
├── data/                              # SQL exports (CSV) + files written by the notebooks
│   ├── session_level_table.csv        # one row per session (SQL session_base)
│   ├── user_level_table.csv           # one row per user (SQL user_base)
│   ├── sessions_clean.csv             # cleaned session table, written by notebook 01
│   ├── users_features.csv             # user table + behavioral features, written by notebook 02
│   └── users_segments.csv             # segment, core perk and K-Means cluster per user, written by notebook 03
├── notebooks/
│   ├── 01_EDA_Cleaning.ipynb          # data cleaning & exploratory data analysis
│   ├── 02_User_Features.ipynb         # user-level features and their distributions
│   └── 03_Segments_Models.ipynb       # rule-based segments, perk mapping, K-Means (DBSCAN to follow)
├── sql/
│   └── JT_session_and_user_base.sql   # cohort filter, session- and user-level tables
├── images/
│   └── TravelTide_ERD.png             # database schema
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
2. Open the notebooks in `notebooks/` and run them **in order (01 → 02 → 03)** – each one writes the CSV the next one reads. **No database connection is needed:**
   - The CSV files are read from `data/` (repo root or one level up from `notebooks/`).
   - If a file is missing, the notebook reads it from the project's Google Drive backup instead (shared as "anyone with the link"), so it also runs in Google Colab.
   - Notebook 01 installs its extra packages (e.g. `airports-py`) automatically if they are missing.
3. *Optional – live database check* (notebook 01, section 1.2, e.g. the gender split before the cohort filter): copy `.env.example` to `.env`, insert the course database URL and set `RUN_LIVE_QUERIES = True`. The `.env` file is listed in `.gitignore`, so the URL is never committed.

> **Opening the CSVs in Excel with German settings:** Excel reads decimals like `1.5` as dates (1 May). Use *Daten → Text in Spalten → Weitere…* and set the decimal separator to `.` – the files themselves are correct.
