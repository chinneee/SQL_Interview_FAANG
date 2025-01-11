-- ================================
-- Q1: Delete duplicate data 
-- ================================
SELECT * FROM cars;

-- Solution 1: Using MIN() Function 
DELETE 
FROM cars
WHERE model_id NOT IN (
    SELECT MIN(model_id) 
    FROM cars 
    GROUP BY model_name, color, brand
); -- Should create back up table while using DELETE

-- Solution 2: Using ROW_NUMBER()
SELECT *
FROM cars
WHERE model_id NOT IN (
    SELECT model_id
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY model_name, color, brand ORDER BY model_id) AS Cate 
        FROM cars
    ) AS t1 
    WHERE Cate > 1
);

-- =========================================================
-- Q2: Display highest and lowest salary to each Department
-- =========================================================
SELECT * FROM employee;

-- Solution 1: Using MIN(), MAX() Window Function
SELECT *,
       MAX(salary) OVER (PARTITION BY dept) AS max_salary,
       MIN(salary) OVER (PARTITION BY dept) AS min_salary
FROM employee;

-- Solution 2: Using First_Value(), Last_Value()
SELECT *,
       FIRST_VALUE(salary) OVER (PARTITION BY dept ORDER BY salary DESC) AS max_salary,
       LAST_VALUE(salary) OVER (PARTITION BY dept ORDER BY salary DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS min_salary
FROM employee;

-- ==========================
-- Q3: Find actual distance 
-- ==========================
SELECT * FROM car_travels;

-- Solution: Using current value - LAG(1)
SELECT *,
       cumulative_distance - LAG(cumulative_distance, 1, 0) OVER (PARTITION BY cars ORDER BY days) AS lag_cum
FROM car_travels;

-- ================================================
-- Q4: Convert the given input to expected output 
-- ================================================
SELECT * FROM src_dest_distance;

-- Solution: Using Self Join 
WITH cte_rnk AS (   
    SELECT *, 
           ROW_NUMBER() OVER (ORDER BY distance) AS rnk
    FROM src_dest_distance
)
SELECT t1.source,
       t1.destination,
       t1.distance
FROM cte_rnk t1
JOIN cte_rnk t2 ON t1.source = t2.destination AND t1.rnk < t2.rnk
ORDER BY source;

-- ========================================
-- Q5: Ungroup the given input data
-- ========================================
SELECT * FROM travel_items;

-- Solution: Using Recursive CTE
WITH cte_recursive AS (
    SELECT *,
           1 AS level 
    FROM travel_items
    UNION ALL
    SELECT c.id, 
           c.item_name,
           c.total_count - 1,
           c.[level] + 1 
    FROM cte_recursive c 
    JOIN travel_items t ON t.id = c.id
    WHERE c.total_count > 1
)
SELECT id, 
       item_name
FROM cte_recursive
ORDER BY 1;

-- =================
-- Q6: IPL Matches 
-- =================
-- Solution for 1: Each team plays with every other team JUST ONCE.
WITH matches AS (
    SELECT ROW_NUMBER() OVER (ORDER BY team_name) AS id, t.*
    FROM teams t
)
SELECT team.team_name AS team, 
       opponent.team_name AS opponent
FROM matches team
JOIN matches opponent ON team.id < opponent.id
ORDER BY team;

-- Solution for 2: Each team plays with every other team TWICE.
WITH matches AS (
    SELECT ROW_NUMBER() OVER (ORDER BY team_name) AS id, t.*
    FROM teams t
)
SELECT team.team_name AS team, 
       opponent.team_name AS opponent
FROM matches team
JOIN matches opponent ON team.id <> opponent.id
ORDER BY team;

-- ==============================
-- Q10: Pizza Delivery Status  
-- ==============================
SELECT * FROM cust_orders;

-- Solution: Using UNION
SELECT DISTINCT c1.cust_name, 'Completed' AS final_status
FROM cust_orders c1
WHERE [status] = 'DELIVERED'
AND NOT EXISTS (
    SELECT 1 
    FROM cust_orders c2 
    WHERE c2.cust_name = c1.cust_name
    AND [status] IN ('SUBMITTED', 'CREATED')
)
UNION 
SELECT DISTINCT c1.cust_name, 'In progress' AS final_status
FROM cust_orders c1
WHERE [status] = 'DELIVERED'
AND EXISTS (
    SELECT 1 
    FROM cust_orders c2 
    WHERE c2.cust_name = c1.cust_name
    AND [status] IN ('SUBMITTED', 'CREATED')
)
UNION 
SELECT DISTINCT c1.cust_name, 'Awaiting Progress' AS final_status
FROM cust_orders c1
WHERE [status] = 'SUBMITTED'
AND NOT EXISTS (
    SELECT 1 
    FROM cust_orders c2 
    WHERE c2.cust_name = c1.cust_name
    AND [status] IN ('DELIVERED', 'CREATED')
)
UNION 
SELECT DISTINCT c1.cust_name, 'Awaiting Submission' AS final_status
FROM cust_orders c1
WHERE [status] = 'CREATED'
AND NOT EXISTS (
    SELECT 1 
    FROM cust_orders c2 
    WHERE c2.cust_name = c1.cust_name
    AND [status] IN ('SUBMITTED', 'DELIVERED')
);
