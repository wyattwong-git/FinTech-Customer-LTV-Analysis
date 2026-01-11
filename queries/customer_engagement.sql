--# Find The Top 10 Highest LTV Spending Behaviour
SELECT 
    active_days,
    last_transaction_days_ago,
    app_usage_frequency,
    preferred_payment_method
FROM fintech_ltv
ORDER BY ltv DESC
LIMIT 10; 

--# Find The Top 10 Lowest LTV Spending Behaviour
SELECT 
    active_days,
    last_transaction_days_ago,
    app_usage_frequency,
    preferred_payment_method
FROM fintech_ltv
ORDER BY ltv
LIMIT 10; 

--# Find the Customer's Average Active Days, Last Transaction Days Ago, LTV by App Usage Frequency
SELECT
    app_usage_frequency,
    AVG(active_days) AS avg_activity,
    AVG(last_transaction_days_ago) AS avg_last_transaction,
    AVG(ltv) AS avg_ltv
FROM fintech_ltv
GROUP BY app_usage_frequency
ORDER BY avg_ltv DESC;

--# Find the Customer's Average Active Days, Last Transaction Days Ago, LTV by Preferred Payment Method
SELECT
    preferred_payment_method,
    AVG(active_days) AS avg_activity,
    AVG(last_transaction_days_ago) AS avg_last_transaction,
    AVG(ltv) AS avg_ltv
FROM fintech_ltv
GROUP BY preferred_payment_method
ORDER BY avg_ltv DESC;

--# Find the Average Active Days and Spending Data by Last Transaction Days Ago Groups
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

--# Find the Average Last Transaction Days Ago and Spending Data by Active Days Groups
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

--# Find Customer's Total Spent per Active Days Ratio
--# These customers are elite spenders and digital wallets should market towards these users to increase activity.
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
--# Find the Customer's that are the Highest Spenders per Active Day (>$2500/Day)
SELECT
    *
FROM ratio_per_active_day
WHERE spent_per_day > 2500.0;

--# Find Customer's Total Transactions per Active Days Ratio
--# These customers are high activity users and digital wallets should focus incentives to these users to increase spending.
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
--# Find the Customer's that are the Highest Transactors per Active Day (>10/Day)
SELECT
    *
FROM ratio_per_active_day
WHERE transaction_per_day > 10.0;