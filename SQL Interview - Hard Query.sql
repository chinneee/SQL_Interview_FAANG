with wh as (
    select * from warehouse),
    days as (
        select top 1 
            event_datetime,
            OnhandQuantity,
            DATEADD(day, -90, event_datetime) as day90,
            DATEADD(day, -180, event_datetime) as day180,
            DATEADD(day, -270, event_datetime) as day270,
            DATEADD(day, -365, event_datetime) as day365
        from wh
        order by event_datetime desc
    ),
    inv_90_days as (
        select 
            Coalesce(sum(OnHandQuantityDelta),0) as DayOld_90
        from wh
        cross join days
        where 
            wh.event_datetime >= days.day90
            and event_type = 'Inbound'
    ),
    inv_90_days_final as (
        select
            case 
                when DayOld_90 > OnhandQuantity then OnhandQuantity
                else DayOld_90
                end as DayOld_90
        from inv_90_days cross join days
    ),
    inv_180_days as (
        select 
            Coalesce(sum(OnHandQuantityDelta),0) as DayOld_180
        from wh
        cross join days
        where 
            wh.event_datetime BETWEEN days.day180 and days.day90
            and event_type = 'Inbound'
    ),
    inv_180_days_final as (
        select
            case  
                when DayOld_180 > (OnhandQuantity - DayOld_90) then (OnhandQuantity - DayOld_90)
                else DayOld_180
                end as DayOld_180
        from inv_180_days cross join days cross join inv_90_days_final
    ),
    inv_270_days as (
        select 
            Coalesce(sum(OnHandQuantityDelta),0) as DayOld_270
        from wh
        cross join days
        where 
            wh.event_datetime BETWEEN days.day270 and days.day180
            and event_type = 'Inbound'
    ),
    inv_270_days_final as (
        select
            case 
                when DayOld_270 > (OnhandQuantity-(DayOld_90 + DayOld_180)) then (OnhandQuantity-(DayOld_90 + DayOld_180))
                else DayOld_270
                end as DayOld_270
        from inv_270_days cross join days cross join inv_90_days_final cross join inv_180_days_final
    ),
    inv_365_days as (
        select 
            Coalesce(sum(OnHandQuantityDelta),0) as DayOld_365
        from wh
        cross join days
        where 
            wh.event_datetime BETWEEN days.day365 and days.day270
            and event_type = 'Inbound'
    ),
    inv_365_days_final as (
        select
            case 
                when DayOld_365 > (OnhandQuantity-(DayOld_90 + DayOld_180 + DayOld_270)) then (OnhandQuantity-(DayOld_90 + DayOld_180 + DayOld_270))
                else DayOld_365
                end as DayOld_365
        from inv_365_days cross join days cross join inv_90_days_final cross join inv_180_days_final cross join inv_270_days_final
    )
select
    DayOld_90 as [0 - 90 days old],
    DayOld_180 as [91 - 180 days old],
    DayOld_270 as [181 - 270 days old],
    DayOld_365 as [271 - 365 days old]
FROM 
    inv_90_days_final, inv_180_days_final, inv_270_days_final, inv_365_days_final

