# SQL Analysis

This folder contains the Microsoft SQL Server (MSSQL) master script used in the Job Market Intelligence Dashboard project.

## Master Script

**File:** `IndiaTechJobMarket_Project.sql`

The script contains Sections 1–29, covering:
- Staging-data validation and missing-value checks
- Numeric and date validation
- Creation and loading of the clean table
- Job-market, salary, skills and competition analysis
- Business queries for exploring the dataset

## Prerequisites

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- A database named `IndiaTechJobMarket`
- A populated `dbo.Jobs_Staging` table with the required columns

The master script assumes the database and staging table already exist. It is not a complete database setup script.

## How to Run

1. Open `IndiaTechJobMarket_Project.sql` in SSMS.
2. Confirm that the database and staging table are configured correctly.
3. Review the script and execute its sections in order.
4. Inspect the output of the validation queries.
5. Verify the analysis results against the project datasets.

**Important:** Section 10 truncates and reloads `dbo.Jobs_Clean`. Run the script only in your intended project database, and back up any data you need to preserve.

## Reproducibility

The script was developed against a local SQL Server environment. Database setup and data import may need to be performed separately before running it on another computer.
