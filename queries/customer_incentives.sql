--# Find The Top 10 Highest LTV Incentive Behaviour
SELECT 
    loyalty_points_earned,
    referral_count,
    cashback_received
FROM fintech_ltv
ORDER BY ltv DESC
LIMIT 10; 

--# Find The Top 10 Lowest LTV Incentive Behaviour
SELECT 
    loyalty_points_earned,
    referral_count,
    cashback_received
FROM fintech_ltv
ORDER BY ltv
LIMIT 10; 

--# Find the Highest Cashback Received Customers
SELECT 
    loyalty_points_earned,
    referral_count,
    cashback_received
FROM fintech_ltv
ORDER BY cashback_received DESC
LIMIT 10;

--# Find the Ratio of Cashback to Total Spent vs. LTV
WITH cashback_per_spent AS (
    SELECT
        cashback_received,
        total_spent,
        ltv,
        ROUND((CAST(cashback_received AS DECIMAL(10, 4)) / total_spent)::NUMERIC, 2) AS cashback_per_dollar_spent
    FROM fintech_ltv
)
SELECT *
FROM cashback_per_spent;