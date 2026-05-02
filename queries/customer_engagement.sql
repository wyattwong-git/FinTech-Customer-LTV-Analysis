-- ============================================================
-- SECTION 3: ENGAGEMENT (Q2 continued — How does engagement shape LTV?)
-- ============================================================

-- Find the Customer's Average Active Days, Last Transaction Days Ago, LTV by App Usage Frequency
SELECT
    app_usage_frequency,
    AVG(active_days) AS avg_activity,
    AVG(last_transaction_days_ago) AS avg_last_transaction,
    AVG(ltv) AS avg_ltv
FROM fintech_ltv
GROUP BY app_usage_frequency
ORDER BY avg_ltv DESC;

-- Find the Customer's Average Active Days, Last Transaction Days Ago, LTV by Preferred Payment Method
SELECT
    preferred_payment_method,
    AVG(active_days) AS avg_activity,
    AVG(last_transaction_days_ago) AS avg_last_transaction,
    AVG(ltv) AS avg_ltv
FROM fintech_ltv
GROUP BY preferred_payment_method
ORDER BY avg_ltv DESC;

-- Find the Average Active Days and Spending Data by Last Transaction Days Ago Groups
SELECT
    CASE
        WHEN last_transaction_days_ago BETWEEN 1 AND 30 THEN 'Less Than a Month'
        WHEN last_transaction_days_ago BETWEEN 30 AND 90 THEN '1 - 3 Months'
        WHEN last_transaction_days_ago BETWEEN 90 AND 180 THEN '3 - 6 Months'
        WHEN last_transaction_days_ago BETWEEN 180 AND 270 THEN '6 - 9 Months'
        ELSE '9+ Months'
    END AS last_transaction_groups,
    COUNT(last_transaction_days_ago) AS count,
    AVG(active_days) AS avg_activity,
    AVG(total_transactions) AS avg_transactions,
    AVG(avg_transaction_value) AS avg_transaction_value,
    AVG(total_spent) AS avg_spent
FROM fintech_ltv
GROUP BY last_transaction_groups
ORDER BY avg_activity DESC;

-- Find the Average Last Transaction Days Ago and Spending Data by Active Days Groups
SELECT
    CASE
        WHEN active_days BETWEEN 1 AND 30 THEN 'Less Than a 30 Days'
        WHEN active_days BETWEEN 30 AND 90 THEN '30 - 90 Days'
        WHEN active_days BETWEEN 90 AND 180 THEN '90 - 180 Days'
        WHEN active_days BETWEEN 180 AND 270 THEN '180 - 270 Days'
        ELSE '270+ Days'
    END AS activity_groups,
    COUNT(active_days) AS count,
    AVG(active_days) AS avg_activity,
    AVG(total_transactions) AS avg_transactions,
    AVG(avg_transaction_value) AS avg_transaction_value,
    AVG(total_spent) AS avg_spent
FROM fintech_ltv
GROUP BY activity_groups
ORDER BY avg_activity DESC;

-- Find Customer's Total Spent per Active Days Ratio (Elite Spenders >$2,500/Day)
WITH ratio_per_active_day AS (
    SELECT
        app_usage_frequency,
        preferred_payment_method,
        active_days,
        last_transaction_days_ago,
        total_spent,
        total_transactions,
        ROUND(CAST(total_spent AS DECIMAL(10, 4)) / active_days, 2) AS spent_per_day
    FROM fintech_ltv
    WHERE active_days > 50
)
SELECT *
FROM ratio_per_active_day
WHERE spent_per_day > 2500.0;

-- Find Customer's Total Transactions per Active Days Ratio (High Activity Users >10/Day)
WITH ratio_per_active_day AS (
    SELECT
        app_usage_frequency,
        preferred_payment_method,
        active_days,
        last_transaction_days_ago,
        total_spent,
        total_transactions,
        ROUND(CAST(total_transactions AS DECIMAL(10, 4)) / active_days, 2) AS transaction_per_day
    FROM fintech_ltv
    WHERE active_days > 50
)
SELECT *
FROM ratio_per_active_day
WHERE transaction_per_day > 10.0;

-- Recency risk — find recently dormant customers with high LTV (churn risk)
-- These are customers the wallet should immediately re-engage
SELECT
    customer_id,
    ltv,
    last_transaction_days_ago,
    total_spent,
    active_days,
    app_usage_frequency
FROM fintech_ltv
WHERE last_transaction_days_ago > 180
    AND ltv > (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ltv) FROM fintech_ltv)
ORDER BY ltv DESC
LIMIT 20;

-- Recency × Frequency × Monetary (RFM) segmentation
-- Segments customers into actionable buckets for targeted campaigns
WITH rfm_scores AS (
    SELECT
        customer_id,
        ltv,
        total_spent,
        total_transactions,
        last_transaction_days_ago,
        NTILE(5) OVER (ORDER BY last_transaction_days_ago ASC) AS recency_score,   -- Lower days = more recent = higher score
        NTILE(5) OVER (ORDER BY total_transactions DESC) AS frequency_score,
        NTILE(5) OVER (ORDER BY total_spent DESC) AS monetary_score
    FROM fintech_ltv
),
rfm_labeled AS (
    SELECT *,
        recency_score + frequency_score + monetary_score AS rfm_total
    FROM rfm_scores
)
SELECT
    CASE
        WHEN rfm_total >= 13 THEN '⭐ Champions'
        WHEN rfm_total >= 10 THEN '✅ Loyal Customers'
        WHEN rfm_total >= 7  THEN '🔄 Potential Loyalists'
        WHEN rfm_total >= 5  THEN '⚠️  At Risk'
        ELSE '❌ Lost Customers'
    END AS rfm_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(ltv)::NUMERIC, 2) AS avg_ltv,
    ROUND(AVG(total_spent)::NUMERIC, 2) AS avg_total_spent,
    ROUND(AVG(total_transactions)::NUMERIC, 2) AS avg_transactions,
    ROUND(AVG(last_transaction_days_ago)::NUMERIC, 2) AS avg_days_since_last
FROM rfm_labeled
GROUP BY rfm_segment
ORDER BY avg_ltv DESC;
