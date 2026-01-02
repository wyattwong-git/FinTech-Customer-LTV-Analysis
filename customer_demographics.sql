--# Display the contents of the 'fintech_ltv' table
SELECT * FROM fintech_ltv;

--# Display Top 10 Highest LTV
SELECT * FROM fintech_ltv
ORDER BY ltv DESC
LIMIT 10; 

--# Display Top 10 Lowest LTV
SELECT * FROM fintech_ltv
ORDER BY ltv
LIMIT 10; 

--# Display Top 10 Highest LTV for Rural Locations
SELECT * FROM fintech_ltv
WHERE location = 'Rural'
ORDER BY ltv DESC
LIMIT 10; 

--# Display Top 10 Highest LTV for Suburban Locations
SELECT * FROM fintech_ltv
WHERE location = 'Suburban'
ORDER BY ltv DESC
LIMIT 10; 

--# Display Top 10 Highest LTV for Urban Locations
SELECT * FROM fintech_ltv
WHERE location = 'Urban'
ORDER BY ltv DESC
LIMIT 10; 

--# Display Top 10 Highest LTV for Low Income Level
SELECT * FROM fintech_ltv
WHERE income_level = 'Low'
ORDER BY ltv DESC
LIMIT 10; 

--# Display Top 10 Highest LTV for Middle Income Level
SELECT * FROM fintech_ltv
WHERE income_level = 'Middle'
ORDER BY ltv DESC
LIMIT 10; 

--# Display Top 10 Highest LTV for High Income Level
SELECT * FROM fintech_ltv
WHERE income_level = 'High'
ORDER BY ltv DESC
LIMIT 10; 

--# Display Customer's Average LTV for Different Age and Income Level Segments
SELECT 
    CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 30 THEN '20 - 30'
        WHEN age BETWEEN 30 AND 40 THEN '30 - 40'
        WHEN age BETWEEN 40 AND 50 THEN '40 - 50'
        WHEN age BETWEEN 50 AND 60 THEN '50 - 60'
        ELSE '60+'
    END AS age_group,
    income_level,
    AVG(ltv) AS avg_ltv,
    COUNT(income_level) AS income_level_count
FROM fintech_ltv
GROUP BY age_group, income_level
ORDER BY avg_ltv DESC;

--# Display Customer's Average LTV by Location
SELECT location,
    AVG(ltv) as avg_ltv
FROM fintech_ltv
GROUP BY location
ORDER BY avg_ltv DESC;

--# Display Customer's Average LTV by Income Level
SELECT income_level,
    AVG(ltv) as avg_ltv
FROM fintech_ltv
GROUP BY income_level
ORDER BY avg_ltv DESC;

--# Display Customer's Average Age by Location
SELECT location,
    AVG(age) as avg_age
FROM fintech_ltv
GROUP BY location
ORDER BY avg_age DESC;

--# Display Customers by Location and Find Distinct Counts of Each Income Level for Each Location
SELECT location,
    income_level,
    COUNT(income_level) AS income_level_count
FROM fintech_ltv
GROUP BY location, income_level
ORDER BY location, income_level;