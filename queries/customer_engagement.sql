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

