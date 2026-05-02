-- ============================================================
-- FINTECH DIGITAL WALLET — CUSTOMER LIFETIME VALUE ANALYSIS
-- Complete SQL EDA Story
-- ============================================================
-- BROAD QUESTION 1: What customer demographics drive high LTV?
-- BROAD QUESTION 2: What engagement and spending patterns define high-value customers?
-- BROAD QUESTION 3: How do incentives and service quality impact LTV?
-- ============================================================


-- ============================================================
-- SECTION 0: DATA OVERVIEW
-- ============================================================

-- Find The contents of the 'fintech_ltv' table
SELECT * FROM fintech_ltv;

-- Summary statistics for all numeric fields
SELECT
    COUNT(*) AS total_customers,
    ROUND(AVG(ltv)::NUMERIC, 2) AS avg_ltv,
    ROUND(MIN(ltv)::NUMERIC, 2) AS min_ltv,
    ROUND(MAX(ltv)::NUMERIC, 2) AS max_ltv,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ltv)::NUMERIC, 2) AS median_ltv,
    ROUND(AVG(total_spent)::NUMERIC, 2) AS avg_total_spent,
    ROUND(AVG(total_transactions)::NUMERIC, 2) AS avg_transactions,
    ROUND(AVG(active_days)::NUMERIC, 2) AS avg_active_days,
    ROUND(AVG(customer_satisfaction_score)::NUMERIC, 2) AS avg_satisfaction
FROM fintech_ltv;

-- LTV distribution by quartile (understand the spread)
SELECT
    CASE
        WHEN ntile_rank = 1 THEN 'Q1 - Low (0-25%)'
        WHEN ntile_rank = 2 THEN 'Q2 - Mid-Low (25-50%)'
        WHEN ntile_rank = 3 THEN 'Q3 - Mid-High (50-75%)'
        WHEN ntile_rank = 4 THEN 'Q4 - High (75-100%)'
    END AS ltv_quartile,
    COUNT(*) AS customer_count,
    ROUND(MIN(ltv)::NUMERIC, 2) AS min_ltv,
    ROUND(MAX(ltv)::NUMERIC, 2) AS max_ltv,
    ROUND(AVG(ltv)::NUMERIC, 2) AS avg_ltv,
    ROUND(AVG(total_transactions)::NUMERIC, 2) AS avg_transactions,
    ROUND(AVG(total_spent)::NUMERIC, 2) AS avg_total_spent
FROM (
    SELECT *, NTILE(4) OVER (ORDER BY ltv) AS ntile_rank
    FROM fintech_ltv
) AS quartiled
GROUP BY ntile_rank
ORDER BY ntile_rank;