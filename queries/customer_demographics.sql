-- ============================================================
-- SECTION 1: DEMOGRAPHICS (Q1 — What demographics drive LTV?)
-- ============================================================

-- Find The Top 10 Highest LTV Demographics
SELECT *
FROM fintech_ltv
ORDER BY ltv DESC
LIMIT 10;

-- Find The Top 10 Lowest LTV Demographics
SELECT *
FROM fintech_ltv
ORDER BY ltv
LIMIT 10;

-- Find The Top 10 Highest LTV for Rural Locations
SELECT
    age,
    location,
    income_level
FROM fintech_ltv
WHERE location = 'Rural'
ORDER BY ltv DESC
LIMIT 10;

-- Find The Top 10 Highest LTV for Suburban Locations
SELECT
    age,
    location,
    income_level
FROM fintech_ltv
WHERE location = 'Suburban'
ORDER BY ltv DESC
LIMIT 10;

-- Find The Top 10 Highest LTV for Urban Locations
SELECT
    age,
    location,
    income_level
FROM fintech_ltv
WHERE location = 'Urban'
ORDER BY ltv DESC
LIMIT 10;

-- Find The Top 10 Highest LTV for Low Income Level
SELECT
    age,
    location,
    income_level
FROM fintech_ltv
WHERE income_level = 'Low'
ORDER BY ltv DESC
LIMIT 10;

-- Find The Top 10 Highest LTV for Middle Income Level
SELECT
    age,
    location,
    income_level
FROM fintech_ltv
WHERE income_level = 'Middle'
ORDER BY ltv DESC
LIMIT 10;

-- Find The Top 10 Highest LTV for High Income Level
SELECT
    age,
    location,
    income_level
FROM fintech_ltv
WHERE income_level = 'High'
ORDER BY ltv DESC
LIMIT 10;

-- Find The Customer's Average LTV for Different Age and Income Level Segments
SELECT
    CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 30 THEN '20 - 30'
        WHEN age BETWEEN 30 AND 40 THEN '30 - 40'
        WHEN age BETWEEN 40 AND 50 THEN '40 - 50'
        WHEN age BETWEEN 50 AND 60 THEN '50 - 60'
        ELSE '60+'
    END AS new_age_group,
    income_level,
    AVG(ltv) AS avg_ltv,
    COUNT(income_level) AS income_level_count
FROM fintech_ltv
GROUP BY new_age_group, income_level
ORDER BY avg_ltv DESC;

-- Find The Customer's Average LTV by Location
SELECT
    location,
    AVG(ltv) as avg_ltv
FROM fintech_ltv
GROUP BY location
ORDER BY avg_ltv DESC;

-- Find The Customer's Average LTV by Income Level
SELECT
    income_level,
    AVG(ltv) as avg_ltv
FROM fintech_ltv
GROUP BY income_level
ORDER BY avg_ltv DESC;

-- Find The Customer's Average Age by Location
SELECT
    location,
    AVG(age) as avg_age
FROM fintech_ltv
GROUP BY location
ORDER BY avg_age DESC;

-- Find The Customers by Location and Find Distinct Counts of Each Income Level for Each Location
SELECT
    location,
    income_level,
    COUNT(income_level) AS income_level_count
FROM fintech_ltv
GROUP BY location, income_level
ORDER BY location, income_level;

-- Demographics are largely uniform — confirm with statistical spread
-- Find The Coefficient of Variation (CV) for LTV across demographic segments to confirm flatness
SELECT
    'Location' AS segment_type,
    location AS segment_value,
    ROUND(AVG(ltv)::NUMERIC, 2) AS avg_ltv,
    ROUND(STDDEV(ltv)::NUMERIC, 2) AS stddev_ltv,
    ROUND((STDDEV(ltv) / NULLIF(AVG(ltv), 0) * 100)::NUMERIC, 2) AS cv_pct
FROM fintech_ltv
GROUP BY location
UNION ALL
SELECT
    'Income Level',
    income_level,
    ROUND(AVG(ltv)::NUMERIC, 2),
    ROUND(STDDEV(ltv)::NUMERIC, 2),
    ROUND((STDDEV(ltv) / NULLIF(AVG(ltv), 0) * 100)::NUMERIC, 2)
FROM fintech_ltv
GROUP BY income_level
UNION ALL
SELECT
    'App Usage',
    app_usage_frequency,
    ROUND(AVG(ltv)::NUMERIC, 2),
    ROUND(STDDEV(ltv)::NUMERIC, 2),
    ROUND((STDDEV(ltv) / NULLIF(AVG(ltv), 0) * 100)::NUMERIC, 2)
FROM fintech_ltv
GROUP BY app_usage_frequency
ORDER BY segment_type, avg_ltv DESC;

-- Find the demographic profile of the top 25% LTV customers vs. bottom 25%
-- Key insight: demographics are NOT the driver of LTV — spending behaviour is.
WITH quartiled AS (
    SELECT *,
           NTILE(4) OVER (ORDER BY ltv) AS calculated_quartile
    FROM fintech_ltv
)
SELECT
    CASE WHEN calculated_quartile = 4 THEN 'Top 25% (High LTV)' ELSE 'Bottom 25% (Low LTV)' END AS ltv_segment,
    ROUND(AVG(age)::NUMERIC, 1) AS avg_age,
    MODE() WITHIN GROUP (ORDER BY location) AS most_common_location,
    MODE() WITHIN GROUP (ORDER BY income_level) AS most_common_income,
    MODE() WITHIN GROUP (ORDER BY app_usage_frequency) AS most_common_usage,
    ROUND(AVG(total_transactions)::NUMERIC, 0) AS avg_transactions,
    ROUND(AVG(total_spent)::NUMERIC, 2) AS avg_total_spent,
    ROUND(AVG(ltv)::NUMERIC, 2) AS avg_ltv
FROM quartiled
WHERE calculated_quartile IN (1, 4)
GROUP BY calculated_quartile
ORDER BY calculated_quartile DESC;
