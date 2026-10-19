# ✈️ TravelTide: Personalized Rewards Program & Customer Segmentation Analysis

MSIT Mastery Project: customer segmentation of TravelTide booking data to design a personalized rewards program. Rule-based segments validated with K-Means and DBSCAN (silhouette-checked), plus new pilot perks. Built with SQL, Python (Pandas, Seaborn, scikit-learn), Tableau and Streamlit.


## Mastery Project — Data Science

### 🎯 Project Overview
The objective of this project is to support TravelTide's Head of Marketing in designing a personalized rewards program that boosts customer engagement and long-term retention. 

Using a relational database spanning customer profiles, session logs, flight bookings, and hotel reservations, I analyze travel behaviors, booking patterns, and discount sensitivity. As the Data Scientist on this initiative, my goal is to translate exploratory findings into actionable recommendations that align perk personalization with distinct customer preferences.

## 📁 Repository Structure
```
TravelTide/
├── data/                              # SQL exports (CSV) + cleaned data
│   ├── session_level_table.csv        # one row per session (SQL session_base)
│   ├── user_level_table.csv           # one row per user (SQL user_base)
│   └── sessions_clean.csv             # cleaned session table, written by notebook 01
├── notebooks/
│   └── 01_EDA_Cleaning.ipynb          # data cleaning & exploratory data analysis
├── sql/
│   └── JT_session_and_user_base.sql   # cohort filter, session- and user-level tables
├── images/
│   └── TravelTide_ERD.png             # database schema
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
2. Open the notebooks in `notebooks/` and run them in order. They read the CSV files from `data/` (or directly from Google Drive if the folder is missing) – **no database connection is needed**.
3. *Optional – live database check* (notebook 01, section 1.2, e.g. the gender split before the cohort filter): copy `.env.example` to `.env`, insert the course database URL and set `RUN_LIVE_QUERIES = True`. The `.env` file is listed in `.gitignore`, so the URL is never committed.
