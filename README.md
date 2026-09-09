# Job Market & Compensation Intelligence Dashboard (2024–2026)

## Executive Summary
An end-to-end business intelligence and analytics project evaluating hiring trends, talent competition ratios, and compensation distributions across 5,000 job postings in India from mid-2024 through April 2026. Built with a custom Executive Dark UI (`#0B111E`) in Power BI, backed by custom DAX time-intelligence logic and SQL/Power Query data modeling.

---

## Dashboard Architecture

### Page 1: Macro Market Overview
Focuses on gross hiring trends, temporal volume shifts, experience tier demand, and workplace model distributions.
![Page 1: Macro Market Overview](page_1_overview.png)

### Page 2: Compensation & Talent Competition
Isolates applicant saturation, candidate-to-opening ratios, and salary benchmarks across organizational types and geographic tiers.
![Page 2: Compensation & Competition](page_2_compensation_competition.png)

---

## Analytical Problems Solved

1. **Truncation Bias in Time-Series Analysis**
   * *Problem*: The dataset terminates in April 2026. A basic Year-over-Year (YoY) calculation compares 4 months of 2026 against 12 months of 2025, creating an artificial 67% contraction.
   * *Solution*: Engineered a dynamic "Like-for-Like" DAX measure matching the identical January–April calendar window across both years, resulting in a like-for-like hiring change of **-7.7%**.

2. **Talent Saturation vs. Gross Opening Scale Distortion**
   * *Problem*: Gross applications (2M) vs. openings (18K) create extreme scale distortions on dual-axis visual distributions.
   * *Solution*: Replaced dual-count visuals with an **Applicants-to-Opening ratio** (`DIVIDE(applicants, openings)`), providing a normalized metric to compare talent competition across industries.

3. **Geographic Compensation Variance**
   * *Problem*: Evaluating whether remote roles show lower baseline compensation compared to metropolitan tech hubs.
   * *Solution*: Benchmarked Tier 1, Remote, and Tier 2 compensation levels to measure observed salary variation.

---

## Key Data Insights

* **Geographic Pay Parity**: Remote roles average **19.9 LPA**, close to Tier-1 roles at **20.0 LPA** and Tier-2 roles at **19.5 LPA**, indicating limited salary variation by location type in this dataset.
* **Competition Ratios by Sector**: While Information Technology leads gross opening volume (5.6K), Manufacturing (**90:1**) and EdTech (**85:1**) exhibit higher applicant-to-opening ratios than IT (**82:1**) or Consulting (**79:1**).
* **Corporate Structure Compensation**: Indian Unicorns show a **33.7%** higher average salary than MNCs (**24.6 LPA** vs. **18.4 LPA**), followed by Startups at **21.5 LPA**.
* **Experience Demand**: Mid-level (3–6 years: 4.9K) and Junior (1–3 years: 4.5K) roles represent the highest hiring volumes, while Fresher roles account for 4.0K openings.

---

## Technical DAX Architecture

### 1. Like-for-Like YTD Hiring Growth
```dax
YTD Hiring Growth % = 
VAR CurrentMaxYear = 
    CALCULATE(
        MAX(Jobs_Clean[year]),
        ALLSELECTED(Jobs_Clean[year])
    )

VAR MaxMonthInYear = 
    CALCULATE(
        MAX(Jobs_Clean[month]),
        Jobs_Clean[year] = CurrentMaxYear,
        ALLSELECTED(Jobs_Clean[month])
    )

VAR CurrentPeriodOpenings = 
    CALCULATE(
        SUM(Jobs_Clean[openings]),
        Jobs_Clean[year] = CurrentMaxYear,
        Jobs_Clean[month] <= MaxMonthInYear
    )

VAR PriorPeriodOpenings = 
    CALCULATE(
        SUM(Jobs_Clean[openings]),
        Jobs_Clean[year] = CurrentMaxYear - 1,
        Jobs_Clean[month] <= MaxMonthInYear,
        REMOVEFILTERS(Jobs_Clean[year]),
        REMOVEFILTERS(Jobs_Clean[month])
    )

RETURN
    IF(
        ISBLANK(PriorPeriodOpenings) || PriorPeriodOpenings = 0,
        BLANK(),
        DIVIDE(CurrentPeriodOpenings - PriorPeriodOpenings, PriorPeriodOpenings)
    )
