-- SOLUTION 1: Using ROW_NUMBER(), FIRST_VALUE(), LAST_VALUE(), UNION
WITH cte_rank AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY employee ORDER BY dates) AS rnk
    FROM emp_attendance
),
cte_present AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY employee ORDER BY dates) AS rownum,
        rnk - ROW_NUMBER() OVER (PARTITION BY employee ORDER BY dates) AS flag
    FROM cte_rank
    WHERE [status] = 'PRESENT'
),
cte_absent AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY employee ORDER BY dates) AS t,
        rnk - ROW_NUMBER() OVER (PARTITION BY employee ORDER BY dates) AS flag
    FROM cte_rank
    WHERE [status] = 'ABSENT'
)

SELECT 
    employee,
    FIRST_VALUE(dates) OVER (PARTITION BY employee, flag ORDER BY employee, dates) AS from_date,
    LAST_VALUE(dates) OVER (PARTITION BY employee, flag ORDER BY employee, dates
                            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS to_date,
    status
FROM cte_present
UNION 
SELECT  
    employee,
    FIRST_VALUE(dates) OVER (PARTITION BY employee, flag ORDER BY employee, dates) AS from_date,
    LAST_VALUE(dates) OVER (PARTITION BY employee, flag ORDER BY employee, dates
                            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS to_date,
    status
FROM cte_absent
ORDER BY employee, from_date;

------------------

-- SOLUTION 2: Using ROW_NUMBER(), DATEADD(), MIN(), MAX()
WITH CTE AS (
    SELECT 
        employee, 
        dates, 
        status, 
        ROW_NUMBER() OVER (PARTITION BY employee, status ORDER BY dates) AS rn
    FROM emp_attendance
),
CTE2 AS (
    SELECT 
        employee, 
        dates, 
        status, 
        DATEADD(day, -rn, dates) AS rn2
    FROM CTE
)
SELECT 
    employee, 
    MIN(dates) AS FROM_DATE, 
    MAX(dates) AS TO_DATE, 
    status
FROM CTE2
GROUP BY 
    employee, 
    status, 
    rn2
ORDER BY 
    employee, 
    FROM_DATE;

