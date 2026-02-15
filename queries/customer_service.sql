--# Find the Average LTV for each Support Tickets Raised to identify where LTV drops off
SELECT
    CASE
        WHEN support_tickets_raised BETWEEN 0 AND 5 THEN '0 - 5'
        WHEN support_tickets_raised BETWEEN 5 AND 10 THEN '5 - 10'
        WHEN support_tickets_raised BETWEEN 10 AND 15 THEN '10 - 15'
        WHEN support_tickets_raised BETWEEN 15 AND 20 THEN '15 - 20'
    END AS support_groups,
    AVG(avg_transaction_value) AS avg_transaction,
    AVG(total_spent) AS avg_spent,
    AVG(customer_satisfaction_score) AS avg_satisfaction,
    AVG(ltv) AS avg_ltv
FROM fintech_ltv
GROUP BY support_groups
ORDER BY avg_ltv DESC;

--# Find which customers have an LTV that is below the median but a Support Tickets Raised count that is in the top 10%
SELECT *
FROM (
    SELECT
        ltv,
        NTILE(10) OVER (ORDER BY support_tickets_raised DESC) AS support_quartile
    FROM fintech_ltv
) AS temp
WHERE support_quartile = 1
    AND ltv < (SELECT AVG(ltv) FROM fintech_ltv)
ORDER BY ltv DESC;

--# Find the Average LTV for each Issue Resolution Time to identify where LTV drops off
SELECT
    CASE
        WHEN issue_resolution_time BETWEEN 0 AND 10 THEN '0 - 10'
        WHEN issue_resolution_time BETWEEN 10 AND 20 THEN '10 - 20'
        WHEN issue_resolution_time BETWEEN 20 AND 30 THEN '20 - 30'
        WHEN issue_resolution_time BETWEEN 30 AND 40 THEN '30 - 40'
        WHEN issue_resolution_time BETWEEN 40 AND 50 THEN '40 - 50'
        WHEN issue_resolution_time BETWEEN 50 AND 60 THEN '50 - 60'
        ELSE '60+'
    END AS resolution_groups,
    AVG(avg_transaction_value) AS avg_transaction,
    AVG(total_spent) AS avg_spent,
    AVG(customer_satisfaction_score) AS avg_satisfaction,
    AVG(ltv) AS avg_ltv
FROM fintech_ltv
GROUP BY resolution_groups
ORDER BY avg_ltv DESC;

--# Find how many customers for each Customer Satisfaction Score but have never raised a support ticket
SELECT
    CASE
        WHEN customer_satisfaction_score = 0 THEN '0'
        WHEN customer_satisfaction_score = 1 THEN '1'
        WHEN customer_satisfaction_score = 2 THEN '2'
        WHEN customer_satisfaction_score = 3 THEN '3'
        WHEN customer_satisfaction_score = 4 THEN '4'
        WHEN customer_satisfaction_score = 5 THEN '5'
        WHEN customer_satisfaction_score = 6 THEN '6'
        WHEN customer_satisfaction_score = 7 THEN '7'
        WHEN customer_satisfaction_score = 8 THEN '8'
        WHEN customer_satisfaction_score = 9 THEN '9'
        WHEN customer_satisfaction_score = 10 THEN '10'
    END AS satisfaction_groups,
    COUNT(*) AS customers_count
FROM fintech_ltv
WHERE support_tickets_raised = 0
GROUP BY satisfaction_groups
ORDER BY customers_count DESC;  

--# Find how satisfied frequent app users are with the service by measuring Customer Satisfaction Score and Support Tickets Raised for each customer
SELECT
    CASE
        WHEN app_usage_frequency = 'Daily' THEN 'Daily'
        WHEN app_usage_frequency = 'Weekly' THEN 'Weekly'
        WHEN app_usage_frequency = 'Monthly' THEN 'Monthly'
    END AS app_frequency_groups,
    AVG(issue_resolution_time) AS avg_resolution_time,
    AVG(support_tickets_raised) AS avg_support_tickets,
    AVG(customer_satisfaction_score) AS avg_satisfaction,
    AVG(ltv) AS avg_ltv
FROM fintech_ltv
GROUP BY app_frequency_groups
ORDER BY avg_ltv DESC;

--# Find the average Issue Resolution Time per total spent for each customer and classify them
WITH resolution_time_per_spent AS (
    SELECT
        support_tickets_raised,
        issue_resolution_time,
        customer_satisfaction_score,
        total_spent,
        ltv,
        ROUND((CAST(issue_resolution_time AS DECIMAL(10, 4)) / total_spent)::NUMERIC, 2) AS resolution_time_per_dollar_spent
    FROM fintech_ltv
    WHERE total_spent > 100
)
SELECT *
FROM resolution_time_per_spent
WHERE resolution_time_per_dollar_spent > 0.05
ORDER BY resolution_time_per_dollar_spent DESC;