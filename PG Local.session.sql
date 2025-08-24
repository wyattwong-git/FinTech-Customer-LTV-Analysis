--# Display the contents of the 'fintech_ltv' table
SELECT * FROM fintech_ltv;

--# Display customer information
SELECT 
    COUNT(DISTINCT customer_id) AS customers,
    AVG(age) AS avg_age,
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    AVG(ltv) AS avg_ltv,
    AVG(total_spent) AS average_total_spent
FROM fintech_ltv;

--# Select only high-income users above 60
SELECT 
    customer_id, age, income_level, ltv
FROM fintech_ltv
WHERE income_level = 'High' and age > 60
ORDER BY ltv DESC;

--# Count different number of values for payment methods
SELECT 
    preferred_payment_method,
    COUNT(*)
FROM fintech_ltv
GROUP BY preferred_payment_method
ORDER BY COUNT(*) DESC;

--# Display LTV Distribution by Income Level
SELECT
    income_level,
    COUNT(*) as customer_count,
    AVG(ltv) as avg_ltv,
    MAX(ltv) as max_ltv,
    MIN(ltv) as min_ltv
FROM fintech_ltv
GROUP BY income_level
ORDER BY avg_ltv DESC;

--# Average spending and transactions by location
SELECT
    location,
    AVG(total_spent) as avg_spent,
    AVG(total_transactions) as avg_transactions,
    AVG(ltv) as avg_ltv
FROM fintech_ltv
GROUP BY location
HAVING AVG(total_spent) > 50000
ORDER BY avg_ltv DESC;