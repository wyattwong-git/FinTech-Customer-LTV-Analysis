--# Display the contents of the 'fintech_ltv' table
SELECT * FROM fintech_ltv;

--# Count different number of values for payment methods
SELECT 
    preferred_payment_method,
    COUNT(*)
FROM fintech_ltv
GROUP BY preferred_payment_method
ORDER BY COUNT(*) DESC;

--# Display the highest total transaction value for each payment method
SELECT
    preferred_payment_method,
    MAX(total_spent) AS max_transaction_value
FROM fintech_ltv
GROUP BY preferred_payment_method;