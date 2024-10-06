use aviation;
show tables;

delete from flights;

alter table flights add column Date1 date;
set sql_safe_updates=0;
update flights 
set date1=STR_TO_DATE(CONCAT(year, '-', month, '-', day), '%Y-%m-%d');
select date1 from flights;
alter table flights drop column day_num;
set sql_safe_updates=0;
alter table flights add column day_num varchar(20);
update flights
set day_num=weekday(date1);

alter table flights add column week_status varchar(20);
update flights
set week_status=if(day_num<=4,'Weekday','weekend');


/*KPI 1-Count of FLIGHT_NUMBER by Week_status*/
SELECT 
    week_status, COUNT(FLIGHT_NUMBER) AS Total_flights
FROM
    flights
GROUP BY week_status;

/*KPI 2-Sum of CANCELLED by Month name*/
SELECT 
    MONTHNAME(f.date1) AS Month,
    SUM(f.cancelled) AS No_Of_Cancelled
FROM
    flights f
        INNER JOIN
    airlines a ON a.iata_code = f.AIRLINE
WHERE
    f.DAY = 1
        AND a.airline = 'jetblue airways'
GROUP BY MONTHNAME(f.date1);


/*KPI 3-State wise & City wise statistics of delay of flights with airline details*/
-- (1)
SELECT 
    a.AIRLINE,
    ap.state,
    ap.city,
    COUNT(f.departure_delay) AS Num_of_airlines_with_delay
FROM
    flights f
        INNER JOIN
    airlines a ON a.iata_code = f.airline
        INNER JOIN
    airports ap ON ap.iata_code = f.ORIGIN_AIRPORT
WHERE
    f.ARRIVAL_DELAY > 15
        AND f.DEPARTURE_DELAY > 15
GROUP BY a.AIRLINE , ap.state , ap.city;

/*KPI 3-Week wise, statistics of delay of flights with airline details*/
-- (2)
SELECT 
    a.AIRLINE,
    DAYNAME(f.date1) AS Day_name,
    COUNT(f.DEPARTURE_DELAY) AS Num_of_airlines_with_delay
FROM
    airlines a
        INNER JOIN
    flights f
    on a.iata_code = f.airline
WHERE
    f.ARRIVAL_DELAY > 15
        AND f.DEPARTURE_DELAY > 15
GROUP BY a.AIRLINE,DAYNAME(f.date1)
order by a.AIRLINE,DAYNAME(f.date1);


/*KPI 4-No of airlines with No departure/arrival delay with distance  between 2500 and 3000*/

select 
    a.airline,
    f.DISTANCE as Distance_between_2500_to_30000,
    count(f.arrival_delay) as Num_of_airlines_with_no_delay
from
    flights f
        inner join
    airlines a on f.AIRLINE = a.iata_code
where
    f.arrival_delay > 15
        and f.DEPARTURE_DELAY > 15
        and f.distance between 2500 and 3000
group by a.airline, f.DISTANCE;


