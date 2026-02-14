--# Find The Customer's Average Total Transactions and Total Spent by Income Level
SELECT 
    income_level,
    COUNT(income_level),
    AVG(total_transactions) AS avg_transactions,
    AVG(total_spent) AS avg_spent
FROM fintech_ltv
GROUP BY income_level;

--# Find The Customer's Max Average Transaction by Location
SELECT 
    location,
    AVG(min_transaction_value) AS avg_min_transaction_value,
    AVG(max_transaction_value) AS avg_max_transaction_value
FROM fintech_ltv
GROUP BY location;

--# Find The Customer's Average Spending Value by Total Transaction Groups
SELECT
    CASE
        WHEN total_transactions BETWEEN 0 AND 100 THEN '0 - 100'
        WHEN total_transactions BETWEEN 100 AND 200 THEN '100 - 200'
        WHEN total_transactions BETWEEN 200 AND 300 THEN '200 - 300'
        WHEN total_transactions BETWEEN 300 AND 400 THEN '300 - 400'
        WHEN total_transactions BETWEEN 400 AND 500 THEN '400 - 500'
        WHEN total_transactions BETWEEN 500 AND 600 THEN '500 - 600'
        WHEN total_transactions BETWEEN 600 AND 700 THEN '600 - 700'
        WHEN total_transactions BETWEEN 700 AND 800 THEN '700 - 800'
        WHEN total_transactions BETWEEN 800 AND 900 THEN '800 - 900'
        ELSE '900 - 1000'
    END AS total_transactions_groups,
    COUNT(total_transactions) AS count,
    AVG(avg_transaction_value) AS avg_transaction,
    AVG(min_transaction_value) AS avg_min_transaction,
    AVG(max_transaction_value) AS avg_max_transaction,
    AVG(total_spent) AS avg_spent
FROM fintech_ltv
GROUP BY total_transactions_groups
ORDER BY avg_transaction DESC;

--# Find The Customers with High LTV but Low Total Transactions
--# These are the customers worth retaining. (NO CUSTOMER DATA FOUND)
SELECT 
    total_transactions,
    ltv
FROM fintech_ltv
WHERE total_transactions < 200 AND ltv > 750000.0;

--# Find The Customers with Low LTV but High Total Transactions
--# These are the customers not worth retaining, but worth targeting incentives to spent more for them.
SELECT 
    total_transactions,
    ltv
FROM fintech_ltv
WHERE total_transactions > 800 AND ltv < 150000.0;

--# Find the Spending Value Consistency of A Customer by Calculating the Average Between the Max and Min Difference.
--# Filter users who have a higher difference than the average to determine who is using the wallet to store large amounts.
--# These users are worth targeting to spend more frequently.
WITH diff AS (
    SELECT 
        total_transactions,
        max_transaction_value,
        min_transaction_value,
        (max_transaction_value - min_transaction_value) AS transaction_difference
    FROM fintech_ltv
),
with_avg AS (
    SELECT
        *,
        AVG(transaction_difference) OVER() AS avg_transaction_diff
    FROM diff
)
SELECT *
FROM with_avg
WHERE transaction_difference > avg_transaction_diff
ORDER BY transaction_difference DESC;

--# Find the Elite Customers (Top 10% in Total Spent, Total Transactions, and Average Transaction Value)
--# Try to retain all these customers.
SELECT *
FROM (
    SELECT
        total_transactions,
        avg_transaction_value,
        total_spent,
        NTILE(10) OVER (ORDER BY total_transactions DESC) AS transaction_quartile,
        NTILE(10) OVER (ORDER BY avg_transaction_value DESC) AS avg_quartile,
        NTILE(10) OVER (ORDER BY total_spent DESC) AS spent_quartile
    FROM fintech_ltv
) AS temp
WHERE transaction_quartile = 1
    AND avg_quartile = 1
    AND spent_quartile = 1;