/* =========================================================
   INDIA TECH JOB MARKET
   MASTER SQL PROJECT
   SECTIONS 1 - 30
   ========================================================= */

USE IndiaTechJobMarket;
GO


/* =========================================================
   SECTION 1: STAGING TABLE VALIDATION
   ========================================================= */

-- 1. Total rows and unique job IDs
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT job_id) AS unique_job_ids
FROM dbo.Jobs_Staging;
GO


/* =========================================================
   SECTION 2: MISSING VALUE CHECK
   ========================================================= */

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN job_id IS NULL OR job_id = '' THEN 1 ELSE 0 END) AS missing_job_id,
    SUM(CASE WHEN job_title IS NULL OR job_title = '' THEN 1 ELSE 0 END) AS missing_job_title,
    SUM(CASE WHEN company IS NULL OR company = '' THEN 1 ELSE 0 END) AS missing_company,
    SUM(CASE WHEN industry IS NULL OR industry = '' THEN 1 ELSE 0 END) AS missing_industry,
    SUM(CASE WHEN city IS NULL OR city = '' THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN salary_lpa IS NULL OR salary_lpa = '' THEN 1 ELSE 0 END) AS missing_salary,
    SUM(CASE WHEN skills_required IS NULL OR skills_required = '' THEN 1 ELSE 0 END) AS missing_skills,
    SUM(CASE WHEN openings IS NULL OR openings = '' THEN 1 ELSE 0 END) AS missing_openings,
    SUM(CASE WHEN applicants IS NULL OR applicants = '' THEN 1 ELSE 0 END) AS missing_applicants
FROM dbo.Jobs_Staging;
GO


/* =========================================================
   SECTION 3: NUMERIC DATA VALIDATION
   ========================================================= */

SELECT
    COUNT(*) AS total_rows,

    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(10,2), salary_lpa) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_salary,

    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(10,2), openings) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_openings,

    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(10,2), applicants) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_applicants,

    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(10,2), company_rating) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_company_rating

FROM dbo.Jobs_Staging;
GO


/* =========================================================
   SECTION 4: DATE VALIDATION
   ========================================================= */

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE
        WHEN TRY_CONVERT(DATE, date_posted) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_dates
FROM dbo.Jobs_Staging;
GO


/* =========================================================
   SECTION 5: SALARY / OPENINGS / APPLICANTS PROFILE
   ========================================================= */

SELECT
    MIN(TRY_CONVERT(DECIMAL(10,2), salary_lpa)) AS min_salary,
    MAX(TRY_CONVERT(DECIMAL(10,2), salary_lpa)) AS max_salary,

    MIN(TRY_CONVERT(DECIMAL(10,2), openings)) AS min_openings,
    MAX(TRY_CONVERT(DECIMAL(10,2), openings)) AS max_openings,

    MIN(TRY_CONVERT(DECIMAL(10,2), applicants)) AS min_applicants,
    MAX(TRY_CONVERT(DECIMAL(10,2), applicants)) AS max_applicants,

    MIN(TRY_CONVERT(DECIMAL(10,2), company_rating)) AS min_rating,
    MAX(TRY_CONVERT(DECIMAL(10,2), company_rating)) AS max_rating

FROM dbo.Jobs_Staging;
GO


/* =========================================================
   SECTION 6: DATE RANGE
   ========================================================= */

SELECT
    MIN(TRY_CONVERT(DATE, date_posted)) AS earliest_date,
    MAX(TRY_CONVERT(DATE, date_posted)) AS latest_date
FROM dbo.Jobs_Staging;
GO


/* =========================================================
   SECTION 7: FLAG DISTRIBUTION
   ========================================================= */

SELECT
    ai_ml_flag,
    cloud_flag,
    data_analytics_flag,
    software_development_flag,
    COUNT(*) AS row_count
FROM dbo.Jobs_Staging
GROUP BY
    ai_ml_flag,
    cloud_flag,
    data_analytics_flag,
    software_development_flag
ORDER BY row_count DESC;
GO


/* =========================================================
   SECTION 8: SAMPLE DATA
   ========================================================= */

SELECT TOP 20 *
FROM dbo.Jobs_Staging;
GO


/* =========================================================
   SECTION 9: CREATE CLEAN TABLE
   ========================================================= */

IF OBJECT_ID('dbo.Jobs_Clean', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Jobs_Clean
    (
        job_id VARCHAR(50),
        job_title VARCHAR(200),
        company VARCHAR(200),
        company_type VARCHAR(100),
        industry VARCHAR(150),
        city VARCHAR(100),
        location_tier VARCHAR(50),
        experience_level VARCHAR(100),
        job_type VARCHAR(100),
        work_mode VARCHAR(50),

        salary_lpa DECIMAL(10,2),
        skills_required VARCHAR(2000),
        education_required VARCHAR(200),

        openings INT,
        applicants INT,
        company_rating DECIMAL(3,2),

        date_posted DATE,
        year INT,
        month INT,
        month_name VARCHAR(30),

        applicants_per_opening DECIMAL(10,2),

        salary_band VARCHAR(50),

        ai_ml_flag INT,
        ai_ml_skills_found VARCHAR(1000),
        cloud_flag INT,
        data_analytics_flag INT,
        software_development_flag INT
    );
END;
GO

/* =========================================================
   SECTION 10: LOAD CLEAN DATA
   ========================================================= */

TRUNCATE TABLE dbo.Jobs_Clean;
GO

INSERT INTO dbo.Jobs_Clean
(
    job_id,
    job_title,
    company,
    company_type,
    industry,
    city,
    location_tier,
    experience_level,
    job_type,
    work_mode,
    salary_lpa,
    skills_required,
    education_required,
    openings,
    applicants,
    company_rating,
    date_posted,
    year,
    month,
    month_name,
    applicants_per_opening,
    salary_band,
    ai_ml_flag,
    ai_ml_skills_found,
    cloud_flag,
    data_analytics_flag,
    software_development_flag
)
SELECT
    job_id,
    job_title,
    company,
    company_type,
    industry,
    city,
    location_tier,
    experience_level,
    job_type,
    work_mode,
    TRY_CONVERT(DECIMAL(10,2), salary_lpa),
    skills_required,
    education_required,
    TRY_CONVERT(INT, TRY_CONVERT(DECIMAL(10,2), openings)),
    TRY_CONVERT(INT, TRY_CONVERT(DECIMAL(10,2), applicants)),
    TRY_CONVERT(DECIMAL(3,2), company_rating),
    TRY_CONVERT(DATE, date_posted),
    TRY_CONVERT(INT, year),
    TRY_CONVERT(INT, month),
    month_name,
    TRY_CONVERT(DECIMAL(10,2), applicants_per_opening),
    salary_band,
    TRY_CONVERT(INT, ai_ml_flag),
    ai_ml_skills_found,
    TRY_CONVERT(INT, cloud_flag),
    TRY_CONVERT(INT, data_analytics_flag),
    TRY_CONVERT(INT, software_development_flag)
FROM dbo.Jobs_Staging;
GO

/* =========================================================
   SECTION 11: JOB MARKET ANALYSIS
   ========================================================= */

-- 11.1 TOTAL JOBS
SELECT
    COUNT(*) AS total_jobs
FROM dbo.Jobs_Clean;
GO


-- 11.2 JOBS BY JOB TYPE
SELECT
    job_type,
    COUNT(*) AS job_count
FROM dbo.Jobs_Clean
GROUP BY job_type
ORDER BY job_count DESC;
GO


-- 11.3 JOBS BY WORK MODE
SELECT
    work_mode,
    COUNT(*) AS job_count
FROM dbo.Jobs_Clean
GROUP BY work_mode
ORDER BY job_count DESC;
GO


-- 11.4 JOBS BY EXPERIENCE LEVEL
SELECT
    experience_level,
    COUNT(*) AS job_count
FROM dbo.Jobs_Clean
GROUP BY experience_level
ORDER BY job_count DESC;
GO


-- 11.5 TOP 10 CITIES BY NUMBER OF JOBS
SELECT TOP 10
    city,
    COUNT(*) AS job_count
FROM dbo.Jobs_Clean
GROUP BY city
ORDER BY job_count DESC;
GO


/* =========================================================
   SECTION 12: SALARY ANALYSIS
   ========================================================= */

-- 12.1 Overall salary statistics
SELECT
    COUNT(*) AS total_jobs,
    MIN(salary_lpa) AS min_salary,
    MAX(salary_lpa) AS max_salary,
    AVG(salary_lpa) AS avg_salary,
    ROUND(AVG(salary_lpa), 2) AS avg_salary_rounded
FROM dbo.Jobs_Clean;
GO


-- 12.2 Average salary by job type
SELECT
    job_type,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    MIN(salary_lpa) AS min_salary,
    MAX(salary_lpa) AS max_salary
FROM dbo.Jobs_Clean
GROUP BY job_type
ORDER BY avg_salary DESC;
GO


-- 12.3 Average salary by experience level
SELECT
    experience_level,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    MIN(salary_lpa) AS min_salary,
    MAX(salary_lpa) AS max_salary
FROM dbo.Jobs_Clean
GROUP BY experience_level
ORDER BY avg_salary DESC;
GO


-- 12.4 Average salary by work mode
SELECT
    work_mode,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY work_mode
ORDER BY avg_salary DESC;
GO


-- 12.5 Average salary by city
SELECT TOP 15
    city,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY city
HAVING COUNT(*) >= 20
ORDER BY avg_salary DESC;
GO


-- 12.6 Salary by salary band
SELECT
    salary_band,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY salary_band
ORDER BY avg_salary DESC;
GO


/* =========================================================
   SECTION 13: JOB MARKET DEMAND & COMPETITION ANALYSIS
   ========================================================= */

-- 13.1 JOB DEMAND BY CAREER AREA
SELECT
    SUM(ai_ml_flag) AS ai_ml_jobs,
    SUM(cloud_flag) AS cloud_jobs,
    SUM(data_analytics_flag) AS data_analytics_jobs,
    SUM(software_development_flag) AS software_development_jobs
FROM dbo.Jobs_Clean;
GO


-- 13.2 TOP 15 JOB TITLES BY DEMAND
SELECT TOP 15
    job_title,
    COUNT(*) AS job_count
FROM dbo.Jobs_Clean
GROUP BY job_title
ORDER BY job_count DESC;
GO


-- 13.3 TOP 15 JOB TITLES BY AVERAGE SALARY
SELECT TOP 15
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY job_title
HAVING COUNT(*) >= 10
ORDER BY avg_salary DESC;
GO


-- 13.4 JOB TYPES BY APPLICATION COMPETITION
SELECT
    job_type,
    COUNT(*) AS job_count,
    ROUND(AVG(applicants), 2) AS avg_applicants,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
GROUP BY job_type
ORDER BY avg_applicants_per_opening DESC;
GO


-- 13.5 TOP 15 MOST COMPETITIVE JOBS
SELECT TOP 15
    job_id,
    job_title,
    company,
    city,
    openings,
    applicants,
    applicants_per_opening
FROM dbo.Jobs_Clean
ORDER BY applicants_per_opening DESC;
GO


-- 13.6 CITIES WITH MOST JOB OPPORTUNITIES
SELECT TOP 15
    city,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY city
ORDER BY job_count DESC;
GO


-- 13.7 CITIES WITH HIGH SALARY + JOB OPPORTUNITIES
SELECT TOP 15
    city,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY city
HAVING COUNT(*) >= 50
ORDER BY avg_salary DESC;
GO


/* =========================================================
   SECTION 14: SKILLS ANALYSIS
   ========================================================= */

-- 14.1 JOBS WITH SKILL INFORMATION
SELECT
    COUNT(*) AS total_jobs,
    SUM(CASE
        WHEN skills_required IS NOT NULL
             AND LTRIM(RTRIM(skills_required)) <> ''
        THEN 1 ELSE 0
    END) AS jobs_with_skills
FROM dbo.Jobs_Clean;
GO


-- 14.2 MOST COMMON SKILL KEYWORDS
SELECT
    skill,
    COUNT(*) AS job_count
FROM
(
    SELECT
        job_id,
        LTRIM(RTRIM(value)) AS skill
    FROM dbo.Jobs_Clean
    CROSS APPLY STRING_SPLIT(skills_required, ',')
) AS SkillData
WHERE skill <> ''
GROUP BY skill
ORDER BY job_count DESC;
GO


-- 14.3 AI/ML JOBS AND THEIR COMMON SKILLS
SELECT TOP 20
    skill,
    COUNT(*) AS job_count
FROM
(
    SELECT
        job_id,
        LTRIM(RTRIM(value)) AS skill
    FROM dbo.Jobs_Clean
    CROSS APPLY STRING_SPLIT(skills_required, ',')
    WHERE ai_ml_flag = 1
) AS SkillData
WHERE skill <> ''
GROUP BY skill
ORDER BY job_count DESC;
GO


-- 14.4 DATA ANALYTICS JOBS AND THEIR COMMON SKILLS
SELECT TOP 20
    skill,
    COUNT(*) AS job_count
FROM
(
    SELECT
        job_id,
        LTRIM(RTRIM(value)) AS skill
    FROM dbo.Jobs_Clean
    CROSS APPLY STRING_SPLIT(skills_required, ',')
    WHERE data_analytics_flag = 1
) AS SkillData
WHERE skill <> ''
GROUP BY skill
ORDER BY job_count DESC;
GO


-- 14.5 CLOUD JOBS AND THEIR COMMON SKILLS
SELECT TOP 20
    skill,
    COUNT(*) AS job_count
FROM
(
    SELECT
        job_id,
        LTRIM(RTRIM(value)) AS skill
    FROM dbo.Jobs_Clean
    CROSS APPLY STRING_SPLIT(skills_required, ',')
    WHERE cloud_flag = 1
) AS SkillData
WHERE skill <> ''
GROUP BY skill
ORDER BY job_count DESC;
GO


-- 14.6 SOFTWARE DEVELOPMENT JOBS AND THEIR COMMON SKILLS
SELECT TOP 20
    skill,
    COUNT(*) AS job_count
FROM
(
    SELECT
        job_id,
        LTRIM(RTRIM(value)) AS skill
    FROM dbo.Jobs_Clean
    CROSS APPLY STRING_SPLIT(skills_required, ',')
    WHERE software_development_flag = 1
) AS SkillData
WHERE skill <> ''
GROUP BY skill
ORDER BY job_count DESC;
GO


/* =========================================================
   SECTION 15: CAREER AREA COMPARISON
   ========================================================= */

-- 15.1 CAREER AREA - JOB VOLUME
SELECT
    SUM(ai_ml_flag) AS ai_ml_jobs,
    SUM(cloud_flag) AS cloud_jobs,
    SUM(data_analytics_flag) AS data_analytics_jobs,
    SUM(software_development_flag) AS software_development_jobs
FROM dbo.Jobs_Clean;
GO


-- 15.2 AI/ML JOBS - SALARY & COMPETITION
SELECT
    COUNT(*) AS ai_ml_jobs,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants), 2) AS avg_applicants,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
WHERE ai_ml_flag = 1;
GO


-- 15.3 DATA ANALYTICS JOBS - SALARY & COMPETITION
SELECT
    COUNT(*) AS data_analytics_jobs,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants), 2) AS avg_applicants,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
WHERE data_analytics_flag = 1;
GO


-- 15.4 CLOUD JOBS - SALARY & COMPETITION
SELECT
    COUNT(*) AS cloud_jobs,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants), 2) AS avg_applicants,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
WHERE cloud_flag = 1;
GO


-- 15.5 SOFTWARE DEVELOPMENT JOBS - SALARY & COMPETITION
SELECT
    COUNT(*) AS software_development_jobs,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants), 2) AS avg_applicants,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
WHERE software_development_flag = 1;
GO


-- 15.6 CAREER AREA - EXPERIENCE LEVEL
SELECT
    experience_level,
    SUM(ai_ml_flag) AS ai_ml_jobs,
    SUM(data_analytics_flag) AS data_analytics_jobs,
    SUM(cloud_flag) AS cloud_jobs,
    SUM(software_development_flag) AS software_development_jobs
FROM dbo.Jobs_Clean
GROUP BY experience_level
ORDER BY
    CASE experience_level
        WHEN 'Fresher (0-1 yr)' THEN 1
        WHEN 'Junior (1-3 yrs)' THEN 2
        WHEN 'Mid (3-6 yrs)' THEN 3
        WHEN 'Senior (6-10 yrs)' THEN 4
        WHEN 'Lead (10+ yrs)' THEN 5
        ELSE 6
    END;
GO


-- 15.7 CAREER AREA - WORK MODE
SELECT
    work_mode,
    SUM(ai_ml_flag) AS ai_ml_jobs,
    SUM(data_analytics_flag) AS data_analytics_jobs,
    SUM(cloud_flag) AS cloud_jobs,
    SUM(software_development_flag) AS software_development_jobs
FROM dbo.Jobs_Clean
GROUP BY work_mode
ORDER BY work_mode;
GO


/* =========================================================
   SECTION 16: FINAL BUSINESS INSIGHTS
   ========================================================= */

-- 16.1 TOP COMPANIES BY NUMBER OF JOB POSTINGS
SELECT TOP 15
    company,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY company
ORDER BY job_count DESC;
GO


-- 16.2 TOP COMPANIES BY AVERAGE SALARY
SELECT TOP 15
    company,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY company
HAVING COUNT(*) >= 10
ORDER BY avg_salary DESC;
GO


-- 16.3 EDUCATION REQUIREMENTS
SELECT
    education_required,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY education_required
ORDER BY job_count DESC;
GO


-- 16.4 JOB OPPORTUNITIES BY LOCATION TIER
SELECT
    location_tier,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
GROUP BY location_tier
ORDER BY job_count DESC;
GO


-- 16.5 JOB POSTINGS BY YEAR
SELECT
    year,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY year
ORDER BY year;
GO


-- 16.6 JOB POSTINGS BY MONTH
SELECT
    month,
    month_name,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY month, month_name
ORDER BY month;
GO


-- 16.7 TOP 20 HIGHEST-PAYING JOBS
SELECT TOP 20
    job_title,
    company,
    city,
    salary_lpa,
    experience_level,
    job_type
FROM dbo.Jobs_Clean
ORDER BY salary_lpa DESC;
GO


-- 16.8 TOP 20 MOST COMPETITIVE JOBS
SELECT TOP 20
    job_title,
    company,
    city,
    openings,
    applicants,
    applicants_per_opening
FROM dbo.Jobs_Clean
ORDER BY applicants_per_opening DESC;
GO


/* =========================================================
   SECTION 17: FINAL CLEAN TABLE VALIDATION
   ========================================================= */

-- 17.1 Check total rows
SELECT
    COUNT(*) AS total_clean_jobs
FROM dbo.Jobs_Clean;
GO


-- 17.2 Check duplicate job IDs
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT job_id) AS unique_job_ids
FROM dbo.Jobs_Clean;
GO


-- 17.3 Check NULL values in important columns
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN job_id IS NULL THEN 1 ELSE 0 END) AS null_job_id,
    SUM(CASE WHEN job_title IS NULL THEN 1 ELSE 0 END) AS null_job_title,
    SUM(CASE WHEN company IS NULL THEN 1 ELSE 0 END) AS null_company,
    SUM(CASE WHEN salary_lpa IS NULL THEN 1 ELSE 0 END) AS null_salary,
    SUM(CASE WHEN openings IS NULL THEN 1 ELSE 0 END) AS null_openings,
    SUM(CASE WHEN applicants IS NULL THEN 1 ELSE 0 END) AS null_applicants,
    SUM(CASE WHEN company_rating IS NULL THEN 1 ELSE 0 END) AS null_company_rating,
    SUM(CASE WHEN date_posted IS NULL THEN 1 ELSE 0 END) AS null_date_posted
FROM dbo.Jobs_Clean;
GO


-- 17.4 Check numeric ranges
SELECT
    MIN(salary_lpa) AS min_salary,
    MAX(salary_lpa) AS max_salary,
    MIN(openings) AS min_openings,
    MAX(openings) AS max_openings,
    MIN(applicants) AS min_applicants,
    MAX(applicants) AS max_applicants,
    MIN(company_rating) AS min_rating,
    MAX(company_rating) AS max_rating
FROM dbo.Jobs_Clean;
GO


-- 17.5 Check date range
SELECT
    MIN(date_posted) AS earliest_date,
    MAX(date_posted) AS latest_date
FROM dbo.Jobs_Clean;
GO


-- 17.6 Preview final clean table
SELECT TOP 20 *
FROM dbo.Jobs_Clean;
GO


/* =========================================================
   SECTION 18: BUSINESS INSIGHTS — JOB MARKET ANALYSIS
   ========================================================= */

-- 18.1 Most in-demand job titles
SELECT TOP 15
    job_title,
    COUNT(*) AS job_count
FROM dbo.Jobs_Clean
GROUP BY job_title
ORDER BY job_count DESC;
GO


-- 18.2 Highest-paying job titles
SELECT TOP 15
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(MIN(salary_lpa), 2) AS min_salary,
    ROUND(MAX(salary_lpa), 2) AS max_salary
FROM dbo.Jobs_Clean
GROUP BY job_title
HAVING COUNT(*) >= 10
ORDER BY avg_salary DESC;
GO


-- 18.3 Jobs by industry
SELECT
    industry,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY industry
ORDER BY job_count DESC;
GO


-- 18.4 Jobs by company type
SELECT
    company_type,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY company_type
ORDER BY job_count DESC;
GO


-- 18.5 Jobs by city
SELECT TOP 15
    city,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY city
ORDER BY job_count DESC;
GO


-- 18.6 Jobs by experience level
SELECT
    experience_level,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY experience_level
ORDER BY job_count DESC;
GO


-- 18.7 Jobs by work mode
SELECT
    work_mode,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY work_mode
ORDER BY job_count DESC;
GO


-- 18.8 Jobs by education requirement
SELECT
    education_required,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY education_required
ORDER BY job_count DESC;
GO


/* =========================================================
   SECTION 19: TECH CAREER DEMAND ANALYSIS
   ========================================================= */

-- 19.1 Overall demand by technology career area
SELECT
    SUM(ai_ml_flag) AS ai_ml_jobs,
    SUM(cloud_flag) AS cloud_jobs,
    SUM(data_analytics_flag) AS data_analytics_jobs,
    SUM(software_development_flag) AS software_development_jobs
FROM dbo.Jobs_Clean;
GO


-- 19.2 Average salary and applicants by career area
SELECT
    'AI/ML' AS career_area,
    SUM(ai_ml_flag) AS job_count,
    ROUND(AVG(CASE WHEN ai_ml_flag = 1 THEN salary_lpa END), 2) AS avg_salary,
    ROUND(AVG(CASE WHEN ai_ml_flag = 1 THEN applicants END), 0) AS avg_applicants
FROM dbo.Jobs_Clean

UNION ALL

SELECT
    'Cloud' AS career_area,
    SUM(cloud_flag),
    ROUND(AVG(CASE WHEN cloud_flag = 1 THEN salary_lpa END), 2),
    ROUND(AVG(CASE WHEN cloud_flag = 1 THEN applicants END), 0)
FROM dbo.Jobs_Clean

UNION ALL

SELECT
    'Data Analytics' AS career_area,
    SUM(data_analytics_flag),
    ROUND(AVG(CASE WHEN data_analytics_flag = 1 THEN salary_lpa END), 2),
    ROUND(AVG(CASE WHEN data_analytics_flag = 1 THEN applicants END), 0)
FROM dbo.Jobs_Clean

UNION ALL

SELECT
    'Software Development' AS career_area,
    SUM(software_development_flag),
    ROUND(AVG(CASE WHEN software_development_flag = 1 THEN salary_lpa END), 2),
    ROUND(AVG(CASE WHEN software_development_flag = 1 THEN applicants END), 0)
FROM dbo.Jobs_Clean;
GO


-- 19.3 AI/ML jobs by experience level
SELECT
    experience_level,
    COUNT(*) AS ai_ml_jobs,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
WHERE ai_ml_flag = 1
GROUP BY experience_level
ORDER BY ai_ml_jobs DESC;
GO


-- 19.4 Data Analytics jobs by experience level
SELECT
    experience_level,
    COUNT(*) AS data_analytics_jobs,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
WHERE data_analytics_flag = 1
GROUP BY experience_level
ORDER BY data_analytics_jobs DESC;
GO


-- 19.5 Cloud jobs by experience level
SELECT
    experience_level,
    COUNT(*) AS cloud_jobs,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
WHERE cloud_flag = 1
GROUP BY experience_level
ORDER BY cloud_jobs DESC;
GO


-- 19.6 Software Development jobs by experience level
SELECT
    experience_level,
    COUNT(*) AS software_development_jobs,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
WHERE software_development_flag = 1
GROUP BY experience_level
ORDER BY software_development_jobs DESC;
GO


-- 19.7 Top AI/ML job titles
SELECT TOP 10
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
WHERE ai_ml_flag = 1
GROUP BY job_title
ORDER BY job_count DESC;
GO


-- 19.8 Top Data Analytics job titles
SELECT TOP 10
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
WHERE data_analytics_flag = 1
GROUP BY job_title
ORDER BY job_count DESC;
GO


-- 19.9 Top Cloud job titles
SELECT TOP 10
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
WHERE cloud_flag = 1
GROUP BY job_title
ORDER BY job_count DESC;
GO


-- 19.10 Top Software Development job titles
SELECT TOP 10
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
WHERE software_development_flag = 1
GROUP BY job_title
ORDER BY job_count DESC;
GO


/* =========================================================
   SECTION 20: SKILLS DEMAND ANALYSIS
   ========================================================= */

-- 20.1 Most demanded skills across all jobs
SELECT TOP 20
    LTRIM(RTRIM(value)) AS skill,
    COUNT(*) AS job_count
FROM dbo.Jobs_Clean
CROSS APPLY STRING_SPLIT(skills_required, ',')
WHERE LTRIM(RTRIM(value)) <> ''
GROUP BY LTRIM(RTRIM(value))
ORDER BY job_count DESC;
GO


-- 20.2 Most demanded skills in AI/ML jobs
SELECT TOP 15
    LTRIM(RTRIM(value)) AS skill,
    COUNT(*) AS job_count
FROM dbo.Jobs_Clean
CROSS APPLY STRING_SPLIT(skills_required, ',')
WHERE ai_ml_flag = 1
  AND LTRIM(RTRIM(value)) <> ''
GROUP BY LTRIM(RTRIM(value))
ORDER BY job_count DESC;
GO


-- 20.3 Most demanded skills in Data Analytics jobs
SELECT TOP 15
    LTRIM(RTRIM(value)) AS skill,
    COUNT(*) AS job_count
FROM dbo.Jobs_Clean
CROSS APPLY STRING_SPLIT(skills_required, ',')
WHERE data_analytics_flag = 1
  AND LTRIM(RTRIM(value)) <> ''
GROUP BY LTRIM(RTRIM(value))
ORDER BY job_count DESC;
GO


-- 20.4 Most demanded skills in Cloud jobs
SELECT TOP 15
    LTRIM(RTRIM(value)) AS skill,
    COUNT(*) AS job_count
FROM dbo.Jobs_Clean
CROSS APPLY STRING_SPLIT(skills_required, ',')
WHERE cloud_flag = 1
  AND LTRIM(RTRIM(value)) <> ''
GROUP BY LTRIM(RTRIM(value))
ORDER BY job_count DESC;
GO


-- 20.5 Most demanded skills in Software Development jobs
SELECT TOP 15
    LTRIM(RTRIM(value)) AS skill,
    COUNT(*) AS job_count
FROM dbo.Jobs_Clean
CROSS APPLY STRING_SPLIT(skills_required, ',')
WHERE software_development_flag = 1
  AND LTRIM(RTRIM(value)) <> ''
GROUP BY LTRIM(RTRIM(value))
ORDER BY job_count DESC;
GO


-- 20.6 Average salary by most demanded skills
SELECT TOP 15
    LTRIM(RTRIM(value)) AS skill,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
CROSS APPLY STRING_SPLIT(skills_required, ',')
WHERE LTRIM(RTRIM(value)) <> ''
GROUP BY LTRIM(RTRIM(value))
HAVING COUNT(*) >= 50
ORDER BY avg_salary DESC;
GO


/* =========================================================
   SECTION 21: JOB COMPETITIVENESS ANALYSIS
   ========================================================= */

-- 21.1 Most competitive individual job postings
SELECT TOP 15
    job_id,
    job_title,
    company,
    city,
    openings,
    applicants,
    applicants_per_opening,
    salary_lpa
FROM dbo.Jobs_Clean
ORDER BY applicants_per_opening DESC;
GO


-- 21.2 Average competition by job type
SELECT
    job_type,
    COUNT(*) AS job_count,
    ROUND(AVG(applicants), 0) AS avg_applicants,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY job_type
ORDER BY avg_applicants_per_opening DESC;
GO


-- 21.3 Competition by experience level
SELECT
    experience_level,
    COUNT(*) AS job_count,
    ROUND(AVG(applicants), 0) AS avg_applicants,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY experience_level
ORDER BY avg_applicants_per_opening DESC;
GO


-- 21.4 Competition by work mode
SELECT
    work_mode,
    COUNT(*) AS job_count,
    ROUND(AVG(applicants), 0) AS avg_applicants,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY work_mode
ORDER BY avg_applicants_per_opening DESC;
GO


-- 21.5 High salary + relatively lower competition
SELECT TOP 15
    job_title,
    company,
    city,
    salary_lpa,
    applicants,
    openings,
    applicants_per_opening
FROM dbo.Jobs_Clean
WHERE salary_lpa >= 20
  AND applicants_per_opening <= 60
ORDER BY salary_lpa DESC;
GO


/* =========================================================
   SECTION 22: COMPANY & MARKET ANALYSIS
   ========================================================= */

-- 22.1 Top companies by number of jobs
SELECT TOP 10
    company,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY company
ORDER BY job_count DESC;
GO


-- 22.2 Top companies by average salary
SELECT TOP 10
    company,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY company
HAVING COUNT(*) >= 10
ORDER BY avg_salary DESC;
GO


-- 22.3 Job count by industry
SELECT
    industry,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY industry
ORDER BY job_count DESC;
GO


-- 22.4 Job count by company type
SELECT
    company_type,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY company_type
ORDER BY job_count DESC;
GO


-- 22.5 Job count by location tier
SELECT
    location_tier,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY location_tier
ORDER BY job_count DESC;
GO


/* =========================================================
   SECTION 23: ADVANCED CAREER & SALARY ANALYSIS
   ========================================================= */

-- 23.1 Average salary by experience level and job type
SELECT
    experience_level,
    job_type,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY experience_level, job_type
ORDER BY experience_level, avg_salary DESC;
GO


-- 23.2 Most competitive jobs by job title
SELECT TOP 15
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY job_title
HAVING COUNT(*) >= 20
ORDER BY avg_applicants_per_opening DESC;
GO


-- 23.3 Highest-paying job titles
SELECT TOP 15
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    MIN(salary_lpa) AS min_salary,
    MAX(salary_lpa) AS max_salary
FROM dbo.Jobs_Clean
GROUP BY job_title
HAVING COUNT(*) >= 20
ORDER BY avg_salary DESC;
GO


-- 23.4 AI/ML jobs by salary band
SELECT
    salary_band,
    COUNT(*) AS ai_ml_jobs,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
WHERE ai_ml_flag = 1
GROUP BY salary_band
ORDER BY avg_salary DESC;
GO


-- 23.5 Data Analytics jobs by experience level
SELECT
    experience_level,
    COUNT(*) AS data_analytics_jobs,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
WHERE data_analytics_flag = 1
GROUP BY experience_level
ORDER BY avg_salary DESC;
GO


-- 23.6 Software Development jobs by work mode
SELECT
    work_mode,
    COUNT(*) AS software_development_jobs,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
WHERE software_development_flag = 1
GROUP BY work_mode
ORDER BY software_development_jobs DESC;
GO


/* =========================================================
   SECTION 24: CAREER OPPORTUNITY ANALYSIS
   ========================================================= */

-- 24.1 Career areas ranked by opportunity
SELECT
    'AI/ML' AS career_area,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants), 2) AS avg_applicants
FROM dbo.Jobs_Clean
WHERE ai_ml_flag = 1

UNION ALL

SELECT
    'Data Analytics',
    COUNT(*),
    ROUND(AVG(salary_lpa), 2),
    ROUND(AVG(applicants), 2)
FROM dbo.Jobs_Clean
WHERE data_analytics_flag = 1

UNION ALL

SELECT
    'Cloud',
    COUNT(*),
    ROUND(AVG(salary_lpa), 2),
    ROUND(AVG(applicants), 2)
FROM dbo.Jobs_Clean
WHERE cloud_flag = 1

UNION ALL

SELECT
    'Software Development',
    COUNT(*),
    ROUND(AVG(salary_lpa), 2),
    ROUND(AVG(applicants), 2)
FROM dbo.Jobs_Clean
WHERE software_development_flag = 1

ORDER BY job_count DESC;
GO


-- 24.2 Career area by salary band
SELECT
    salary_band,
    SUM(ai_ml_flag) AS ai_ml_jobs,
    SUM(data_analytics_flag) AS data_analytics_jobs,
    SUM(cloud_flag) AS cloud_jobs,
    SUM(software_development_flag) AS software_development_jobs
FROM dbo.Jobs_Clean
GROUP BY salary_band
ORDER BY
    CASE salary_band
        WHEN '0-5 LPA' THEN 1
        WHEN '5-10 LPA' THEN 2
        WHEN '10-20 LPA' THEN 3
        WHEN '20-50 LPA' THEN 4
        WHEN '50+ LPA' THEN 5
        ELSE 6
    END;
GO


-- 24.3 Career area by work mode
SELECT
    work_mode,
    SUM(ai_ml_flag) AS ai_ml_jobs,
    SUM(data_analytics_flag) AS data_analytics_jobs,
    SUM(cloud_flag) AS cloud_jobs,
    SUM(software_development_flag) AS software_development_jobs
FROM dbo.Jobs_Clean
GROUP BY work_mode
ORDER BY work_mode;
GO


-- 24.4 Career area by job type
SELECT
    job_type,
    SUM(ai_ml_flag) AS ai_ml_jobs,
    SUM(data_analytics_flag) AS data_analytics_jobs,
    SUM(cloud_flag) AS cloud_jobs,
    SUM(software_development_flag) AS software_development_jobs
FROM dbo.Jobs_Clean
GROUP BY job_type
ORDER BY job_type;
GO


-- 24.5 Career area by experience level
SELECT
    experience_level,
    SUM(ai_ml_flag) AS ai_ml_jobs,
    SUM(data_analytics_flag) AS data_analytics_jobs,
    SUM(cloud_flag) AS cloud_jobs,
    SUM(software_development_flag) AS software_development_jobs
FROM dbo.Jobs_Clean
GROUP BY experience_level
ORDER BY
    CASE experience_level
        WHEN 'Fresher (0-1 yr)' THEN 1
        WHEN 'Junior (1-3 yrs)' THEN 2
        WHEN 'Mid (3-6 yrs)' THEN 3
        WHEN 'Senior (6-10 yrs)' THEN 4
        WHEN 'Lead (10+ yrs)' THEN 5
        ELSE 6
    END;
GO


/* =========================================================
   SECTION 25: OPPORTUNITY SCORE ANALYSIS
   ========================================================= */

-- 25.1 Career opportunity score
SELECT
    'AI/ML' AS career_area,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening,
    ROUND(
        (COUNT(*) * AVG(salary_lpa)) /
        NULLIF(AVG(applicants_per_opening), 0),
        2
    ) AS opportunity_score
FROM dbo.Jobs_Clean
WHERE ai_ml_flag = 1

UNION ALL

SELECT
    'Data Analytics',
    COUNT(*),
    ROUND(AVG(salary_lpa), 2),
    ROUND(AVG(applicants_per_opening), 2),
    ROUND(
        (COUNT(*) * AVG(salary_lpa)) /
        NULLIF(AVG(applicants_per_opening), 0),
        2
    )
FROM dbo.Jobs_Clean
WHERE data_analytics_flag = 1

UNION ALL

SELECT
    'Cloud',
    COUNT(*),
    ROUND(AVG(salary_lpa), 2),
    ROUND(AVG(applicants_per_opening), 2),
    ROUND(
        (COUNT(*) * AVG(salary_lpa)) /
        NULLIF(AVG(applicants_per_opening), 0),
        2
    )
FROM dbo.Jobs_Clean
WHERE cloud_flag = 1

UNION ALL

SELECT
    'Software Development',
    COUNT(*),
    ROUND(AVG(salary_lpa), 2),
    ROUND(AVG(applicants_per_opening), 2),
    ROUND(
        (COUNT(*) * AVG(salary_lpa)) /
        NULLIF(AVG(applicants_per_opening), 0),
        2
    )
FROM dbo.Jobs_Clean
WHERE software_development_flag = 1

ORDER BY opportunity_score DESC;
GO


-- 25.2 Best job titles for freshers
SELECT TOP 15
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
WHERE experience_level = 'Fresher (0-1 yr)'
GROUP BY job_title
HAVING COUNT(*) >= 10
ORDER BY avg_salary DESC;
GO


-- 25.3 Best job titles for junior professionals
SELECT TOP 15
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
WHERE experience_level = 'Junior (1-3 yrs)'
GROUP BY job_title
HAVING COUNT(*) >= 10
ORDER BY avg_salary DESC;
GO


-- 25.4 Highest salary with reasonable competition
SELECT TOP 15
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
GROUP BY job_title
HAVING COUNT(*) >= 20
   AND AVG(applicants_per_opening) <= 85
ORDER BY avg_salary DESC;
GO


/* =========================================================
   SECTION 26: FINAL DATA QUALITY VALIDATION
   ========================================================= */

-- 26.1 Total rows and unique job IDs
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT job_id) AS unique_job_ids
FROM dbo.Jobs_Clean;
GO


-- 26.2 Check important NULL values
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN job_id IS NULL THEN 1 ELSE 0 END) AS null_job_id,
    SUM(CASE WHEN job_title IS NULL THEN 1 ELSE 0 END) AS null_job_title,
    SUM(CASE WHEN company IS NULL THEN 1 ELSE 0 END) AS null_company,
    SUM(CASE WHEN salary_lpa IS NULL THEN 1 ELSE 0 END) AS null_salary,
    SUM(CASE WHEN openings IS NULL THEN 1 ELSE 0 END) AS null_openings,
    SUM(CASE WHEN applicants IS NULL THEN 1 ELSE 0 END) AS null_applicants,
    SUM(CASE WHEN company_rating IS NULL THEN 1 ELSE 0 END) AS null_company_rating,
    SUM(CASE WHEN date_posted IS NULL THEN 1 ELSE 0 END) AS null_date_posted
FROM dbo.Jobs_Clean;
GO


-- 26.3 Validate numeric ranges
SELECT
    MIN(salary_lpa) AS min_salary,
    MAX(salary_lpa) AS max_salary,
    MIN(openings) AS min_openings,
    MAX(openings) AS max_openings,
    MIN(applicants) AS min_applicants,
    MAX(applicants) AS max_applicants,
    MIN(company_rating) AS min_rating,
    MAX(company_rating) AS max_rating
FROM dbo.Jobs_Clean;
GO


-- 26.4 Validate date range
SELECT
    MIN(date_posted) AS earliest_date,
    MAX(date_posted) AS latest_date
FROM dbo.Jobs_Clean;
GO


-- 26.5 Check for duplicate job IDs
SELECT
    job_id,
    COUNT(*) AS duplicate_count
FROM dbo.Jobs_Clean
GROUP BY job_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
GO


/* =========================================================
   SECTION 27: FINAL BUSINESS ANALYSIS
   ========================================================= */

-- 27.1 TOP 10 HIGHEST-PAYING JOB TITLES
SELECT TOP 10
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(MIN(salary_lpa), 2) AS min_salary,
    ROUND(MAX(salary_lpa), 2) AS max_salary
FROM dbo.Jobs_Clean
GROUP BY job_title
HAVING COUNT(*) >= 20
ORDER BY avg_salary DESC;
GO


-- 27.2 TOP 10 MOST IN-DEMAND JOB TITLES
SELECT TOP 10
    job_title,
    COUNT(*) AS job_count
FROM dbo.Jobs_Clean
GROUP BY job_title
ORDER BY job_count DESC;
GO


-- 27.3 SALARY BY EXPERIENCE LEVEL
SELECT
    experience_level,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY experience_level
ORDER BY avg_salary DESC;
GO


-- 27.4 JOB DEMAND BY CITY
SELECT TOP 10
    city,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY city
ORDER BY job_count DESC;
GO


-- 27.5 HIGHEST-PAYING CITIES
SELECT TOP 10
    city,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY city
HAVING COUNT(*) >= 30
ORDER BY avg_salary DESC;
GO


-- 27.6 SALARY BY WORK MODE
SELECT
    work_mode,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
GROUP BY work_mode
ORDER BY avg_salary DESC;
GO


-- 27.7 SALARY BY JOB TYPE
SELECT
    job_type,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
GROUP BY job_type
ORDER BY avg_salary DESC;
GO


-- 27.8 SALARY BY EDUCATION
SELECT
    education_required,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY education_required
HAVING COUNT(*) >= 50
ORDER BY avg_salary DESC;
GO


-- 27.9 MOST IN-DEMAND SKILLS
SELECT TOP 15
    skill,
    COUNT(*) AS job_count
FROM
(
    SELECT TRIM(value) AS skill
    FROM dbo.Jobs_Clean
    CROSS APPLY STRING_SPLIT(skills_required, ',')
    WHERE TRIM(value) <> ''
) AS skill_data
GROUP BY skill
ORDER BY job_count DESC;
GO


--27.10 CAREER AREA COMPARISON 

SELECT
    'AI/ML' AS career_area,
    SUM(ai_ml_flag) AS job_count,
    ROUND(AVG(CASE WHEN ai_ml_flag = 1 THEN salary_lpa END), 2) AS avg_salary,
    ROUND(AVG(CASE WHEN ai_ml_flag = 1 THEN applicants END), 0) AS avg_applicants
FROM dbo.Jobs_Clean

UNION ALL

SELECT
    'Cloud' AS career_area,
    SUM(cloud_flag) AS job_count,
    ROUND(AVG(CASE WHEN cloud_flag = 1 THEN salary_lpa END), 2) AS avg_salary,
    ROUND(AVG(CASE WHEN cloud_flag = 1 THEN applicants END), 0) AS avg_applicants
FROM dbo.Jobs_Clean

UNION ALL

SELECT
    'Data Analytics' AS career_area,
    SUM(data_analytics_flag) AS job_count,
    ROUND(AVG(CASE WHEN data_analytics_flag = 1 THEN salary_lpa END), 2) AS avg_salary,
    ROUND(AVG(CASE WHEN data_analytics_flag = 1 THEN applicants END), 0) AS avg_applicants
FROM dbo.Jobs_Clean

UNION ALL

SELECT
    'Software Development' AS career_area,
    SUM(software_development_flag) AS job_count,
    ROUND(AVG(CASE WHEN software_development_flag = 1 THEN salary_lpa END), 2) AS avg_salary,
    ROUND(AVG(CASE WHEN software_development_flag = 1 THEN applicants END), 0) AS avg_applicants
FROM dbo.Jobs_Clean

ORDER BY job_count DESC;
GO


-- 27.11 MOST COMPETITIVE JOBS
SELECT TOP 10
    job_title,
    company,
    city,
    openings,
    applicants,
    ROUND(applicants_per_opening, 2) AS applicants_per_opening,
    salary_lpa
FROM dbo.Jobs_Clean
WHERE openings > 0
ORDER BY applicants_per_opening DESC;
GO


-- 27.12 TOP COMPANIES BY JOB COUNT
SELECT TOP 10
    company,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY company
ORDER BY job_count DESC;
GO


-- 27.13 SALARY BAND ANALYSIS
SELECT
    salary_band,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
GROUP BY salary_band
ORDER BY avg_salary DESC;
GO


-- 27.14 JOB MARKET TREND BY YEAR
SELECT
    year,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY year
ORDER BY year;
GO


-- 27.15 FINAL DATASET SUMMARY
SELECT
    COUNT(*) AS total_jobs,
    COUNT(DISTINCT job_id) AS unique_job_ids,
    ROUND(AVG(salary_lpa), 2) AS overall_avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS overall_avg_applicants_per_opening
FROM dbo.Jobs_Clean;
GO


/* =========================================================
   SECTION 28: REFINED BUSINESS ANALYSIS
   ========================================================= */

-- 28.1 JOB DEMAND BY ACTUAL CITY
SELECT TOP 10
    city,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
WHERE city IS NOT NULL
  AND LTRIM(RTRIM(city)) <> ''
  AND city <> 'Remote'
GROUP BY city
ORDER BY job_count DESC;
GO


-- 28.2 HIGHEST-PAYING ACTUAL CITIES
SELECT TOP 10
    city,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
WHERE city IS NOT NULL
  AND LTRIM(RTRIM(city)) <> ''
  AND city <> 'Remote'
GROUP BY city
HAVING COUNT(*) >= 30
ORDER BY avg_salary DESC;
GO


-- 28.3 WORK MODE DISTRIBUTION
SELECT
    work_mode,
    COUNT(*) AS job_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM dbo.Jobs_Clean),
        2
    ) AS job_percentage,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY work_mode
ORDER BY job_count DESC;
GO


-- 28.4 EXPERIENCE VS SALARY
SELECT
    experience_level,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
GROUP BY experience_level
ORDER BY
    CASE experience_level
        WHEN 'Fresher (0-1 yr)' THEN 1
        WHEN 'Junior (1-3 yrs)' THEN 2
        WHEN 'Mid (3-6 yrs)' THEN 3
        WHEN 'Senior (6-10 yrs)' THEN 4
        WHEN 'Lead (10+ yrs)' THEN 5
        ELSE 6
    END;
GO


-- 28.5 CAREER AREA COMPARISON
SELECT
    career_area,
    job_count,
    avg_salary,
    avg_applicants
FROM
(
    SELECT
        'AI/ML' AS career_area,
        SUM(ai_ml_flag) AS job_count,
        ROUND(AVG(CASE WHEN ai_ml_flag = 1 THEN salary_lpa END), 2) AS avg_salary,
        ROUND(AVG(CASE WHEN ai_ml_flag = 1 THEN applicants END), 0) AS avg_applicants
    FROM dbo.Jobs_Clean

    UNION ALL

    SELECT
        'Data Analytics',
        SUM(data_analytics_flag),
        ROUND(AVG(CASE WHEN data_analytics_flag = 1 THEN salary_lpa END), 2),
        ROUND(AVG(CASE WHEN data_analytics_flag = 1 THEN applicants END), 0)
    FROM dbo.Jobs_Clean

    UNION ALL

    SELECT
        'Cloud',
        SUM(cloud_flag),
        ROUND(AVG(CASE WHEN cloud_flag = 1 THEN salary_lpa END), 2),
        ROUND(AVG(CASE WHEN cloud_flag = 1 THEN applicants END), 0)
    FROM dbo.Jobs_Clean

    UNION ALL

    SELECT
        'Software Development',
        SUM(software_development_flag),
        ROUND(AVG(CASE WHEN software_development_flag = 1 THEN salary_lpa END), 2),
        ROUND(AVG(CASE WHEN software_development_flag = 1 THEN applicants END), 0)
    FROM dbo.Jobs_Clean
) AS career_analysis
ORDER BY job_count DESC;
GO


-- 28.6 YEARLY JOB MARKET TREND
SELECT
    year,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY year
ORDER BY year;
GO


-- 28.7 TOP 10 COMPANIES BY JOB POSTINGS
SELECT TOP 10
    company,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY company
ORDER BY job_count DESC;
GO


-- 28.8 TOP 10 MOST COMPETITIVE JOB POSTINGS
SELECT TOP 10
    job_title,
    company,
    city,
    openings,
    applicants,
    ROUND(applicants_per_opening, 2) AS applicants_per_opening,
    salary_lpa
FROM dbo.Jobs_Clean
WHERE openings > 0
ORDER BY applicants_per_opening DESC;
GO


-- 28.9 TOP 10 JOB TITLES BY DEMAND
SELECT TOP 10
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY job_title
ORDER BY job_count DESC;
GO


-- 28.10 FINAL PROJECT SUMMARY
SELECT
    COUNT(*) AS total_jobs,
    COUNT(DISTINCT job_id) AS unique_job_ids,
    ROUND(AVG(salary_lpa), 2) AS overall_avg_salary,
    ROUND(AVG(applicants), 2) AS overall_avg_applicants,
    ROUND(AVG(applicants_per_opening), 2) AS overall_avg_applicants_per_opening,
    MIN(date_posted) AS earliest_date,
    MAX(date_posted) AS latest_date
FROM dbo.Jobs_Clean;
GO


/* =========================================================
   SECTION 29: FINAL OPPORTUNITY & CAREER INSIGHTS
   ========================================================= */

-- 29.1 SALARY VS COMPETITION
SELECT
    salary_band,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants), 0) AS avg_applicants,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
GROUP BY salary_band
ORDER BY
    CASE salary_band
        WHEN '0-5 LPA' THEN 1
        WHEN '5-10 LPA' THEN 2
        WHEN '10-20 LPA' THEN 3
        WHEN '20-50 LPA' THEN 4
        WHEN '50+ LPA' THEN 5
        ELSE 6
    END;
GO


-- 29.2 FRESHER OPPORTUNITY ANALYSIS
SELECT
    COUNT(*) AS fresher_jobs,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants), 0) AS avg_applicants,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening,
    MIN(salary_lpa) AS min_salary,
    MAX(salary_lpa) AS max_salary
FROM dbo.Jobs_Clean
WHERE experience_level = 'Fresher (0-1 yr)';
GO


-- Fresher jobs by career area
SELECT
    'AI/ML' AS career_area,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
WHERE experience_level = 'Fresher (0-1 yr)'
  AND ai_ml_flag = 1

UNION ALL

SELECT
    'Data Analytics',
    COUNT(*),
    ROUND(AVG(salary_lpa), 2),
    ROUND(AVG(applicants_per_opening), 2)
FROM dbo.Jobs_Clean
WHERE experience_level = 'Fresher (0-1 yr)'
  AND data_analytics_flag = 1

UNION ALL

SELECT
    'Cloud',
    COUNT(*),
    ROUND(AVG(salary_lpa), 2),
    ROUND(AVG(applicants_per_opening), 2)
FROM dbo.Jobs_Clean
WHERE experience_level = 'Fresher (0-1 yr)'
  AND cloud_flag = 1

UNION ALL

SELECT
    'Software Development',
    COUNT(*),
    ROUND(AVG(salary_lpa), 2),
    ROUND(AVG(applicants_per_opening), 2)
FROM dbo.Jobs_Clean
WHERE experience_level = 'Fresher (0-1 yr)'
  AND software_development_flag = 1

ORDER BY job_count DESC;
GO


-- Fresher jobs by work mode
SELECT
    work_mode,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
WHERE experience_level = 'Fresher (0-1 yr)'
GROUP BY work_mode
ORDER BY job_count DESC;
GO


-- Fresher jobs by job type
SELECT
    job_type,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
WHERE experience_level = 'Fresher (0-1 yr)'
GROUP BY job_type
ORDER BY job_count DESC;
GO


-- 29.3 SKILLS VS SALARY
SELECT
    skill,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM
(
    SELECT
        salary_lpa,
        applicants_per_opening,
        'Python' AS skill
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%Python%'

    UNION ALL

    SELECT
        salary_lpa,
        applicants_per_opening,
        'SQL'
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%SQL%'

    UNION ALL

    SELECT
        salary_lpa,
        applicants_per_opening,
        'AWS'
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%AWS%'

    UNION ALL

    SELECT
        salary_lpa,
        applicants_per_opening,
        'Docker'
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%Docker%'

    UNION ALL

    SELECT
        salary_lpa,
        applicants_per_opening,
        'Java'
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%Java%'

    UNION ALL

    SELECT
        salary_lpa,
        applicants_per_opening,
        'React'
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%React%'

    UNION ALL

    SELECT
        salary_lpa,
        applicants_per_opening,
        'TensorFlow'
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%TensorFlow%'

    UNION ALL

    SELECT
        salary_lpa,
        applicants_per_opening,
        'PyTorch'
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%PyTorch%'

    UNION ALL

    SELECT
        salary_lpa,
        applicants_per_opening,
        'NLP'
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%NLP%'

    UNION ALL

    SELECT
        salary_lpa,
        applicants_per_opening,
        'MongoDB'
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%MongoDB%'

    UNION ALL

    SELECT
        salary_lpa,
        applicants_per_opening,
        'PostgreSQL'
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%PostgreSQL%'

    UNION ALL

    SELECT
        salary_lpa,
        applicants_per_opening,
        'Power BI'
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%Power BI%'
) AS skill_data
GROUP BY skill
ORDER BY avg_salary DESC;
GO


-- 29.4 SKILL DEMAND VS SALARY
SELECT
    skill,
    job_count,
    avg_salary,
    avg_applicants_per_opening
FROM
(
    SELECT
        'Python' AS skill,
        COUNT(*) AS job_count,
        AVG(salary_lpa) AS avg_salary,
        AVG(applicants_per_opening) AS avg_applicants_per_opening
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%Python%'

    UNION ALL

    SELECT
        'SQL',
        COUNT(*),
        AVG(salary_lpa),
        AVG(applicants_per_opening)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%SQL%'

    UNION ALL

    SELECT
        'AWS',
        COUNT(*),
        AVG(salary_lpa),
        AVG(applicants_per_opening)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%AWS%'

    UNION ALL

    SELECT
        'Docker',
        COUNT(*),
        AVG(salary_lpa),
        AVG(applicants_per_opening)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%Docker%'

    UNION ALL

    SELECT
        'React',
        COUNT(*),
        AVG(salary_lpa),
        AVG(applicants_per_opening)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%React%'

    UNION ALL

    SELECT
        'Java',
        COUNT(*),
        AVG(salary_lpa),
        AVG(applicants_per_opening)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%Java%'

    UNION ALL

    SELECT
        'REST APIs',
        COUNT(*),
        AVG(salary_lpa),
        AVG(applicants_per_opening)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%REST APIs%'

    UNION ALL

    SELECT
        'PostgreSQL',
        COUNT(*),
        AVG(salary_lpa),
        AVG(applicants_per_opening)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%PostgreSQL%'
) AS skill_analysis
ORDER BY job_count DESC;
GO


-- 29.5 COMPANY TYPE VS EXPERIENCE LEVEL
SELECT
    company_type,
    experience_level,
    COUNT(*) AS job_count,
    AVG(salary_lpa) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY
    company_type,
    experience_level
ORDER BY
    company_type,
    CASE experience_level
        WHEN 'Fresher (0-1 yr)' THEN 1
        WHEN 'Junior (1-3 yrs)' THEN 2
        WHEN 'Mid (3-6 yrs)' THEN 3
        WHEN 'Senior (6-10 yrs)' THEN 4
        WHEN 'Lead (10+ yrs)' THEN 5
    END;
GO


-- 29.6 WORK MODE VS CAREER AREA
SELECT
    career_area,
    work_mode,
    COUNT(*) AS job_count,
    AVG(salary_lpa) AS avg_salary,
    AVG(applicants_per_opening) AS avg_applicants_per_opening
FROM
(
    SELECT
        'AI/ML' AS career_area,
        work_mode,
        salary_lpa,
        applicants_per_opening
    FROM dbo.Jobs_Clean
    WHERE ai_ml_flag = 1

    UNION ALL

    SELECT
        'Cloud',
        work_mode,
        salary_lpa,
        applicants_per_opening
    FROM dbo.Jobs_Clean
    WHERE cloud_flag = 1

    UNION ALL

    SELECT
        'Data Analytics',
        work_mode,
        salary_lpa,
        applicants_per_opening
    FROM dbo.Jobs_Clean
    WHERE data_analytics_flag = 1

    UNION ALL

    SELECT
        'Software Development',
        work_mode,
        salary_lpa,
        applicants_per_opening
    FROM dbo.Jobs_Clean
    WHERE software_development_flag = 1
) AS career_data
GROUP BY
    career_area,
    work_mode
ORDER BY
    career_area,
    job_count DESC;
GO


-- 29.7 CAREER AREA SALARY TREND BY YEAR
SELECT
    career_area,
    year,
    COUNT(*) AS job_count,
    AVG(salary_lpa) AS avg_salary
FROM
(
    SELECT
        'AI/ML' AS career_area,
        year,
        salary_lpa
    FROM dbo.Jobs_Clean
    WHERE ai_ml_flag = 1

    UNION ALL

    SELECT
        'Cloud',
        year,
        salary_lpa
    FROM dbo.Jobs_Clean
    WHERE cloud_flag = 1

    UNION ALL

    SELECT
        'Data Analytics',
        year,
        salary_lpa
    FROM dbo.Jobs_Clean
    WHERE data_analytics_flag = 1

    UNION ALL

    SELECT
        'Software Development',
        year,
        salary_lpa
    FROM dbo.Jobs_Clean
    WHERE software_development_flag = 1
) AS career_year_data
GROUP BY
    career_area,
    year
ORDER BY
    year,
    avg_salary DESC;
GO


/* =========================================================
   SECTION 30: EXECUTIVE SUMMARY / KEY KPIs
   ========================================================= */

-- 30.1 Overall market KPIs
SELECT
    COUNT(*) AS total_jobs,
    COUNT(DISTINCT job_id) AS unique_job_ids,
    ROUND(AVG(salary_lpa), 2) AS overall_avg_salary,
    ROUND(AVG(applicants), 0) AS overall_avg_applicants,
    ROUND(AVG(applicants_per_opening), 2) AS overall_avg_applicants_per_opening,
    MIN(date_posted) AS earliest_date,
    MAX(date_posted) AS latest_date
FROM dbo.Jobs_Clean;
GO


-- 30.2 Top career areas by job volume
SELECT
    career_area,
    job_count,
    ROUND(avg_salary, 2) AS avg_salary,
    ROUND(avg_applicants, 0) AS avg_applicants
FROM
(
    SELECT
        'AI/ML' AS career_area,
        COUNT(*) AS job_count,
        AVG(salary_lpa) AS avg_salary,
        AVG(applicants) AS avg_applicants
    FROM dbo.Jobs_Clean
    WHERE ai_ml_flag = 1

    UNION ALL

    SELECT
        'Cloud',
        COUNT(*),
        AVG(salary_lpa),
        AVG(applicants)
    FROM dbo.Jobs_Clean
    WHERE cloud_flag = 1

    UNION ALL

    SELECT
        'Data Analytics',
        COUNT(*),
        AVG(salary_lpa),
        AVG(applicants)
    FROM dbo.Jobs_Clean
    WHERE data_analytics_flag = 1

    UNION ALL

    SELECT
        'Software Development',
        COUNT(*),
        AVG(salary_lpa),
        AVG(applicants)
    FROM dbo.Jobs_Clean
    WHERE software_development_flag = 1
) AS career_summary
ORDER BY job_count DESC;
GO


-- 30.3 Top 10 job titles by demand
SELECT TOP 10
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY job_title
ORDER BY job_count DESC;
GO


-- 30.4 Top 10 highest-paying job titles
SELECT TOP 10
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY job_title
HAVING COUNT(*) >= 20
ORDER BY avg_salary DESC;
GO


-- 30.5 Top 10 most demanded skills
SELECT TOP 10
    skill,
    job_count
FROM
(
    SELECT 'Python' AS skill, COUNT(*) AS job_count
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%Python%'

    UNION ALL

    SELECT 'SQL', COUNT(*)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%SQL%'

    UNION ALL

    SELECT 'AWS', COUNT(*)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%AWS%'

    UNION ALL

    SELECT 'Docker', COUNT(*)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%Docker%'

    UNION ALL

    SELECT 'Java', COUNT(*)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%Java%'

    UNION ALL

    SELECT 'REST APIs', COUNT(*)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%REST APIs%'

    UNION ALL

    SELECT 'PostgreSQL', COUNT(*)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%PostgreSQL%'

    UNION ALL

    SELECT 'React', COUNT(*)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%React%'

    UNION ALL

    SELECT 'TensorFlow', COUNT(*)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%TensorFlow%'

    UNION ALL

    SELECT 'NLP', COUNT(*)
    FROM dbo.Jobs_Clean
    WHERE skills_required LIKE '%NLP%'
) AS skill_summary
ORDER BY job_count DESC;
GO


-- 30.6 Salary band distribution
SELECT
    salary_band,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants), 0) AS avg_applicants
FROM dbo.Jobs_Clean
GROUP BY salary_band
ORDER BY
    CASE salary_band
        WHEN '0-5 LPA' THEN 1
        WHEN '5-10 LPA' THEN 2
        WHEN '10-20 LPA' THEN 3
        WHEN '20-50 LPA' THEN 4
        WHEN '50+ LPA' THEN 5
    END;
GO


-- 30.7 Job distribution by experience level
SELECT
    experience_level,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary,
    ROUND(AVG(applicants_per_opening), 2) AS avg_applicants_per_opening
FROM dbo.Jobs_Clean
GROUP BY experience_level
ORDER BY
    CASE experience_level
        WHEN 'Fresher (0-1 yr)' THEN 1
        WHEN 'Junior (1-3 yrs)' THEN 2
        WHEN 'Mid (3-6 yrs)' THEN 3
        WHEN 'Senior (6-10 yrs)' THEN 4
        WHEN 'Lead (10+ yrs)' THEN 5
    END;
GO


-- 30.8 Work mode summary
SELECT
    work_mode,
    COUNT(*) AS job_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM dbo.Jobs_Clean), 2
    ) AS job_percentage,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY work_mode
ORDER BY job_count DESC;
GO


-- 30.9 Top cities by job volume
SELECT TOP 10
    city,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY city
ORDER BY job_count DESC;
GO


-- 30.10 Year-wise market trend
SELECT
    year,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_lpa), 2) AS avg_salary
FROM dbo.Jobs_Clean
GROUP BY year
ORDER BY year;
GO

