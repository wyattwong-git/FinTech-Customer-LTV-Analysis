--# Find the Ratio of Cashback to Total Spent vs. LTV
WITH cashback_per_spent AS (
    SELECT
        cashback_received,
        total_spent,
        ltv,
        ROUND((CAST(cashback_received AS DECIMAL(10, 4)) / total_spent)::NUMERIC, 2) AS cashback_per_dollar_spent
    FROM fintech_ltv
    WHERE total_spent > 100
)
SELECT *
FROM cashback_per_spent
WHERE cashback_per_dollar_spent > 0.05
ORDER BY cashback_per_dollar_spent DESC;

--# Find Ratio of Loyalty Points to Total Spent vs. LTV
WITH loyalty_per_spent AS (
    SELECT
        loyalty_points_earned,
        total_spent,
        ltv,
        ROUND((CAST(loyalty_points_earned AS DECIMAL(10, 4)) / total_spent)::NUMERIC, 2) AS loyalty_per_dollar_spent
    FROM fintech_ltv
    WHERE total_spent > 100
)
SELECT *
FROM loyalty_per_spent
WHERE loyalty_per_dollar_spent > 0.05
ORDER BY loyalty_per_dollar_spent DESC;

--# Find the Average Total Spent for each Loyalty Points Earned Tier
SELECT
    CASE
        WHEN loyalty_points_earned BETWEEN 0 AND 1000 THEN '0 - 1000'
        WHEN loyalty_points_earned BETWEEN 1000 AND 2000 THEN '1000 - 2000'
        WHEN loyalty_points_earned BETWEEN 2000 AND 3000 THEN '2000 - 3000'
        WHEN loyalty_points_earned BETWEEN 3000 AND 4000 THEN '3000 - 4000'
        ELSE '4000 - 5000'
    END AS loyalty_groups,
    AVG(avg_transaction_value) AS avg_transaction,
    AVG(total_spent) AS avg_spent
FROM fintech_ltv
GROUP BY loyalty_groups
ORDER BY avg_transaction DESC;

--# Find the Average Total Spent for each Cashback Received Tier
SELECT
    CASE
        WHEN cashback_received BETWEEN 0 AND 20 THEN '0 - 20'
        WHEN cashback_received BETWEEN 20 AND 40 THEN '20 - 40'
        WHEN cashback_received BETWEEN 40 AND 60 THEN '40 - 60'
        ELSE '60 - 80'
    END AS cashback_groups,
    AVG(avg_transaction_value) AS avg_transaction,
    AVG(total_spent) AS avg_spent
FROM fintech_ltv
GROUP BY cashback_groups
ORDER BY avg_transaction DESC;

--# Find the Average Total Spent for each Referral Count Tier
SELECT
    CASE
        WHEN referral_count BETWEEN 0 AND 10 THEN '0 - 10'
        WHEN referral_count BETWEEN 10 AND 20 THEN '10 - 20'
        WHEN referral_count BETWEEN 20 AND 30 THEN '20 - 30'
        WHEN referral_count BETWEEN 30 AND 40 THEN '30 - 40'
        ELSE '40 - 50'
    END AS referral_groups,
    AVG(avg_transaction_value) AS avg_transaction,
    AVG(total_spent) AS avg_spent
FROM fintech_ltv
GROUP BY referral_groups
ORDER BY avg_transaction DESC;

--# Find Users who are in the top 10% for both Cashback Received and Loyalty Points Earned
SELECT *
FROM (
    SELECT
        cashback_received,
        loyalty_points_earned,
        ltv,
        NTILE(10) OVER (ORDER BY cashback_received DESC) AS cashback_quartile,
        NTILE(10) OVER (ORDER BY loyalty_points_earned DESC) AS loyalty_quartile,
        NTILE(10) OVER (ORDER BY ltv DESC) AS ltv_quartile
    FROM fintech_ltv
) AS temp
WHERE cashback_quartile = 1
    AND loyalty_quartile = 1
    AND ltv_quartile = 1;

--# Find Users who acquire the most referrals and calculate a "Total Network Value" by adding a bonus to a customer's LTV for every referral count)
WITH network_value AS (
    SELECT
        ltv,
        referral_count,
        ltv + (referral_count * 100) AS total_network_value,
        RANK() OVER (ORDER BY ltv DESC) AS ltv_rank
    FROM fintech_ltv
)
SELECT *,
    RANK() OVER (ORDER BY total_network_value DESC) AS network_rank
FROM network_value;