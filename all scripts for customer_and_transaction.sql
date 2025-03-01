-- 1 задание
SELECT c.job_industry_category,
       COUNT(*) AS client_count
FROM hw.customer c  
GROUP BY c.job_industry_category
ORDER BY client_count DESC;

-- 2 задание
SELECT  SUM(t.list_price),
		c.job_industry_category,
		TO_CHAR(t.transaction_date, 'YYYY-MM') AS year_month
FROM hw.transaction t 
JOIN hw.customer c 
  ON t.customer_id = c.customer_id
GROUP BY c.job_industry_category, year_month
ORDER BY c.job_industry_category, year_month ASC;

-- 3 задание
SELECT 	t.brand, 
		COUNT(*) AS online_order_count
FROM hw.transaction t
JOIN hw.customer c ON t.customer_id = c.customer_id
WHERE c.job_industry_category = 'IT'
  AND t.order_status = 'Approved' 
  AND t.online_order = TRUE 
GROUP BY t.brand
ORDER BY online_order_count DESC;
  
-- 4 задание (через группировку)
SELECT 	c.customer_id,
    	SUM(t.list_price) AS total_transaction_sum,
    	MAX(t.list_price) AS max_transaction,
    	MIN(t.list_price) AS min_transaction,
    	COUNT(t.transaction_id) AS transaction_count
FROM hw.transaction t 
JOIN hw.customer c 
  ON t.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY total_transaction_sum DESC, transaction_count DESC;

-- 4 задание (через окно)
SELECT DISTINCT
    c.customer_id,
    SUM(t.list_price) OVER (PARTITION BY c.customer_id) AS total_transaction_sum,
    MAX(t.list_price) OVER (PARTITION BY c.customer_id) AS max_transaction,
    MIN(t.list_price) OVER (PARTITION BY c.customer_id) AS min_transaction,
    COUNT(t.transaction_id) OVER (PARTITION BY c.customer_id) AS transaction_count
FROM hw.customer c
JOIN hw.transaction t ON c.customer_id = t.customer_id
ORDER BY total_transaction_sum DESC, transaction_count DESC;
  
--5 задание (минимум)
SELECT 
    c.first_name,
    c.last_name,
    SUM(t.list_price) AS total_transaction_sum
FROM hw.customer c
JOIN hw.transaction t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(t.list_price) = (
    SELECT MIN(total_sum)
    FROM (
        SELECT SUM(t2.list_price) AS total_sum
        FROM hw.transaction t2
        GROUP BY t2.customer_id
    ) AS min_transaction_sum
);

--5 задание (максимум)
SELECT 
    c.first_name,
    c.last_name,
    SUM(t.list_price) AS total_transaction_sum
FROM hw.customer c
JOIN hw.transaction t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(t.list_price) = (
    SELECT MAX(total_sum)
    FROM (
        SELECT SUM(t2.list_price) AS total_sum
        FROM hw.transaction t2
        GROUP BY t2.customer_id
    ) AS max_transaction_sum
);

-- 6 задание
SELECT 
    customer_id,
    transaction_id,
    transaction_date,
    list_price
FROM (
    SELECT 
        t.customer_id,
        t.transaction_id,
        t.transaction_date,
        t.list_price,
        ROW_NUMBER() OVER (PARTITION BY t.customer_id ORDER BY t.transaction_date) AS rn
    FROM hw.transaction t
) AS first_transaction
WHERE rn = 1;
  
-- 7 задание
SELECT 
    c.first_name,
    c.last_name,
    c.job_title,
    MAX(intervals.interval_days) AS max_interval_days
FROM (
    SELECT 
        t.customer_id,
        (t.transaction_date - LAG(t.transaction_date) 
        	OVER (PARTITION BY t.customer_id ORDER BY t.transaction_date)) AS interval_days
    FROM hw.transaction t
) AS intervals
JOIN hw.customer c 
    ON intervals.customer_id = c.customer_id
WHERE intervals.interval_days IS NOT NULL
GROUP BY c.customer_id, c.first_name, c.last_name, c.job_title
ORDER BY max_interval_days DESC
LIMIT 1;