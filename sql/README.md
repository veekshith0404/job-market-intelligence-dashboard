## Project Files and Data

### Dataset

This project uses the **India Tech Jobs 2024–2026 | Salary & Skills** dataset from Kaggle, created by Sridip Basu.

The dataset creator describes the records as simulated data. Therefore, the results in this project should be interpreted as findings from a simulated dataset, not as independently verified statistics about India's actual technology job market.

The dataset covers June 2024 through April 2026:
- 2024: June–December
- 2025: January–December
- 2026: January–April

### Data Files

- [Original Kaggle dataset](data/raw/india_job_market_2024_2026.csv)
- [Cleaned dataset](data/cleaned/india_job_market_cleaned_v2.csv)
- [Processed dataset](data/processed/india_job_market_final_pre_sql_v1.csv)

### SQL Analysis

The project uses Microsoft SQL Server (MSSQL) for data validation, cleaning and business analysis.

- [Master SQL script — Sections 1–29](sql/IndiaTechJobMarket_Project.sql)
- [SQL documentation and prerequisites](sql/README.md)

### Power BI Dashboard

The repository includes the Power BI report, PDF export and dashboard screenshots. Open the PBIX file using Power BI Desktop to inspect the report.
