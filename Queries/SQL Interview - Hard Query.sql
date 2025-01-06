-- Generate an inventory age report which would show the distribution of remaining inventory across the length of time the inventory has been sitting at the warehouse.
-- Classify the inventory on hand across the below 4 buckets to denote the time the inventory has been lying the warehouse.
    /*
    0-90 days old 
    91-180 days old
    181-270 days old
    271 – 365 days old
    */

WITH wh AS (
    SELECT * 
    FROM warehouse
),
days AS (
    SELECT TOP 1 
        event_datetime,
        OnhandQuantity,
        DATEADD(day, -90, event_datetime) AS day90,
        DATEADD(day, -180, event_datetime) AS day180,
        DATEADD(day, -270, event_datetime) AS day270,
        DATEADD(day, -365, event_datetime) AS day365
    FROM wh
    ORDER BY event_datetime DESC
),
inv_90_days AS (
    SELECT 
        COALESCE(SUM(OnHandQuantityDelta), 0) AS DayOld_90
    FROM wh
    CROSS JOIN days
    WHERE 
        wh.event_datetime >= days.day90
        AND event_type = 'Inbound'
),
inv_90_days_final AS (
    SELECT
        CASE 
            WHEN DayOld_90 > OnhandQuantity THEN OnhandQuantity
            ELSE DayOld_90
        END AS DayOld_90
    FROM inv_90_days 
    CROSS JOIN days
),
inv_180_days AS (
    SELECT 
        COALESCE(SUM(OnHandQuantityDelta), 0) AS DayOld_180
    FROM wh
    CROSS JOIN days
    WHERE 
        wh.event_datetime BETWEEN days.day180 AND days.day90
        AND event_type = 'Inbound'
),
inv_180_days_final AS (
    SELECT
        CASE  
            WHEN DayOld_180 > (OnhandQuantity - DayOld_90) THEN (OnhandQuantity - DayOld_90)
            ELSE DayOld_180
        END AS DayOld_180
    FROM inv_180_days 
    CROSS JOIN days 
    CROSS JOIN inv_90_days_final
),
inv_270_days AS (
    SELECT 
        COALESCE(SUM(OnHandQuantityDelta), 0) AS DayOld_270
    FROM wh
    CROSS JOIN days
    WHERE 
        wh.event_datetime BETWEEN days.day270 AND days.day180
        AND event_type = 'Inbound'
),
inv_270_days_final AS (
    SELECT
        CASE 
            WHEN DayOld_270 > (OnhandQuantity - (DayOld_90 + DayOld_180)) THEN (OnhandQuantity - (DayOld_90 + DayOld_180))
            ELSE DayOld_270
        END AS DayOld_270
    FROM inv_270_days 
    CROSS JOIN days 
    CROSS JOIN inv_90_days_final 
    CROSS JOIN inv_180_days_final
),
inv_365_days AS (
    SELECT 
        COALESCE(SUM(OnHandQuantityDelta), 0) AS DayOld_365
    FROM wh
    CROSS JOIN days
    WHERE 
        wh.event_datetime BETWEEN days.day365 AND days.day270
        AND event_type = 'Inbound'
),
inv_365_days_final AS (
    SELECT
        CASE 
            WHEN DayOld_365 > (OnhandQuantity - (DayOld_90 + DayOld_180 + DayOld_270)) THEN (OnhandQuantity - (DayOld_90 + DayOld_180 + DayOld_270))
            ELSE DayOld_365
        END AS DayOld_365
    FROM inv_365_days 
    CROSS JOIN days 
    CROSS JOIN inv_90_days_final 
    CROSS JOIN inv_180_days_final 
    CROSS JOIN inv_270_days_final
)
SELECT
    DayOld_90 AS [0 - 90 days old],
    DayOld_180 AS [91 - 180 days old],
    DayOld_270 AS [181 - 270 days old],
    DayOld_365 AS [271 - 365 days old]
FROM 
    inv_90_days_final, 
    inv_180_days_final, 
    inv_270_days_final, 
    inv_365_days_final;
