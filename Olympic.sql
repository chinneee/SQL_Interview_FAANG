select * from noc_regions;
select top 100 * from athlete_events;

--How many olympics games have been held?
Select 
    count(distinct Games) as total_games
from   
    athlete_events;

--List down all Olympics games held so far.
WITH cte_TotalCountries AS (
    SELECT
        Games,
        COUNT(DISTINCT nr.region) AS total_countries
    FROM 
        athlete_events ae 
    JOIN 
        noc_regions nr 
    ON 
        ae.NOC = nr.NOC
    GROUP BY 
        Games
)
, cte_DetectMaxMin as
    (select 
        (Select Games
        from cte_TotalCountries
        where total_countries = (select max(total_countries) from cte_TotalCountries)) as year_with_max_countries,
        max(total_countries) as max_countries,
        (select Games
        from cte_TotalCountries
        where total_countries = (select min(total_countries) from cte_TotalCountries)) as year_with_min_countries,
        min(total_countries) as min_countries
    from cte_TotalCountries)
select
    CONCAT(year_with_max_countries, ' - ', max_countries) as year_with_max_countries,
    CONCAT(year_with_min_countries, ' - ', min_countries) as year_with_min_countries
from cte_DetectMaxMin;


--Which nation has participated in all of the olympic games?
select
    NOC,
    region
from noc_regions
where noc in (
    select noc
    from athlete_events
    group by noc
    having count(distinct Games) = (select count(distinct Games) from athlete_events)
);

--Identify the sport which was played in all summer olympics.
with cte_summersports as    
    (select
        distinct sport as distinct_sport,
        [Year]
    from athlete_events
    where season = 'Summer')
select
    distinct_sport,
    count(distinct [Year]) as total_years
from cte_summersports
group by distinct_sport
having count(distinct [Year]) = 
    (select count(distinct Games) from athlete_events where season = 'Summer');

--Which Sports were just played only once in the olympics?
with t1 as
    (select
        distinct Games,
        Sport
    from athlete_events)
, t2 as
    (select
        sport,
        count(1) as total_sports
    from t1
    group by Sport)
select
    t2.*, t1.Games
from t1
join t2
on t1.Sport = t2.Sport
where total_sports = 1;

--Fetch the total no of sports played in each olympic games.
select 
    Games,
    count(distinct sport) as total_sports
from athlete_events
group by Games;
--Fetch details of the oldest athletes to win a gold medal.
select
    ID,
    Name,
    sex,
    Age,
    Height,
    Weight,
    Team,
    Medal
from 
    athlete_events
where 
    Medal = 'Gold' and
    Age = (select max(Age) from athlete_events where Medal = 'Gold' and Age <> 'NA');
--Find the Ratio of male and female athletes participated in all olympic games.
select *,
    ROUND(Male_ratio/ CAST(Female_ratio as float),2) as ratio
from     
    (select top 1
        (select count(*) from athlete_events where Sex = 'M') as Male_ratio,
        (select count(*) from athlete_events where Sex = 'F') as Female_ratio
    from athlete_events) as t1

--Fetch the top 5 athletes who have won the most gold medals.
with t1 as
            (select name, team, count(1) as total_gold_medals
            from athlete_events
            where medal = 'Gold'
            group by name, team
            order by total_gold_medals desc),
        t2 as
            (select *, dense_rank() over (order by total_gold_medals desc) as rnk
            from t1)
    select name, team, total_gold_medals
    from t2
    where rnk <= 5;

--Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

--Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

--List down total gold, silver and broze medals won by each country.

--List down total gold, silver and broze medals won by each country corresponding to each olympic games.

--Identify which country won the most gold, most silver and most bronze medals in each olympic games.

--Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

--Which countries have never won gold medal but have won silver/bronze medals?

--In which Sport/event, India has won highest medals.

--Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.