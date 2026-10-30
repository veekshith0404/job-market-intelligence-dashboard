# SQL Analysis

This folder contains the Microsoft SQL Server (MSSQL) master script used in the Job Market Intelligence Dashboard project.
## Master Script

**File:** `IndiaTechJobMarket_Project.sql`

The master script has 30 numbered sections covering staging-data validation, missing-value and type checks, date validation, clean-table creation and loading, and job-market, skills, salary, competition, and executive KPI queries. The section comments have been numbered sequentially; the query logic is unchanged.
## Prerequisites

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- A database named `IndiaTechJobMarket`
- A populated `dbo.Jobs_Staging` table with the required columns

The script assumes the database and staging table already exist. It is not a complete database setup or CSV-import script.
## How to Run

1. Open `IndiaTechJobMarket_Project.sql` in SSMS.
2. Confirm that the database and staging table are configured correctly.
3. Review the script and execute the sections in order.
4. Inspect the output of the validation queries.
5. Verify the analysis results against the project datasets.

**Important:** Section 10 truncates and reloads `dbo.Jobs_Clean`. Run the script only in your intended project database, and back up any data you need to preserve.
## Reproducibility

The script was developed against a local SQL Server environment. Database setup and data import may need to be performed separately before running it on another computer. The complete SQL-to-Power BI refresh workflow has not been independently tested on a fresh computer.

## Power BI Data Source Configuration

The Power BI report was developed using a local SQL Server Express instance.

**Original connection:**
- **Server:** `.\SQLEXPRESS`
- **Database:** `IndiaTechJobMarket`
- **Table:** `dbo.Jobs_Clean`

To use the report on another computer:

1. Install and configure Microsoft SQL Server.
2. Create the `IndiaTechJobMarket` database and populate `dbo.Jobs_Staging` with the required project data. Then execute `IndiaTechJobMarket_Project.sql` in SSMS to validate the data and create and load `dbo.Jobs_Clean`..
3. Open the PBIX file in Power BI Desktop.
4. Go to **File → Options and settings → Data source settings**.
5. Select the SQL Server connection and choose **Change Source**.
6. Enter the local SQL Server instance name and confirm the database.

The connection must point to a database containing the expected `dbo.Jobs_Clean` schema. Configure credentials and database permissions as required.
