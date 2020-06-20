select t1.name, count(*) - 1
from tableX t1
where t1.TimeStarted >= (select max(t2.TimeStarted)
from tableX t2
where t2.Name = t1.Name
    and t2.status = 1)
group by t1.name;



with t1 as(
with
    apps
    as
    (
        SELECT samples.id as id, samples.device_id as device_id, battery_level, app_processes.created_at as d
        FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
        WHERE name = 'com.android.chrome' and importance='Foreground app'
    
    
    
    
    
     LIMIT 20)
SELECT T1.id,
    T1.device_id as device_id,
    T1.battery_level as battery_level,
    T1.d as TimeStarted,
    MIN(T2.d) AS Date2,
    TIME_TO_SEC(TIMEDIFF(T1.d, MIN(T2.d))) AS DaysDiff
FROM apps T1
    LEFT JOIN apps T2
    ON T1.device_id = T2.device_id
        AND T2.d > T1.d
GROUP BY T1.device_id, T1.d
)
select t1.device_id, count(*) - 1, GROUP_CONCAT(t1.battery_level)
from t1
where t1.TimeStarted <= (select MIN(t2.TimeStarted)
from t1 t2
where t2.device_id = t1.device_id
    and t2.DaysDiff < -40)
group by t1.device_id;




SELECT devices.id, GROUP_CONCAT(battery_level) GroupedName
FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
WHERE name = 'com.android.chrome' and importance='Foreground app'
LIMIT 1;


SELECT devices.id, GROUP_CONCAT(battery_level) GroupedName
FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
WHERE name = 'com.android.chrome' and importance='Foreground app'
GROUP BY devices.id
LIMIT 10



with t1 as(
with
    apps
    as
    (
        SELECT samples.id as id, samples.device_id as device_id, battery_level, app_processes.created_at as d
        FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
        WHERE name = 'com.android.chrome' and importance='Foreground app'
    
    
    
    
    
     LIMIT 20)
SELECT T1.id,
    T1.device_id as device_id,
    T1.battery_level as battery_level,
    T1.d as TimeStarted,
    MIN(T2.d) AS Date2,
    TIME_TO_SEC(TIMEDIFF(T1.d, MIN(T2.d))) AS DaysDiff
FROM apps T1
    LEFT JOIN apps T2
    ON T1.device_id = T2.device_id
        AND T2.d > T1.d
GROUP BY T1.device_id, T1.d
)
select device_id, TimeStarted, (Date2 - INTERVAL
1 SECOND) as Date2
    from t1
    where t1.DaysDiff < -40

with t1 as(
with
    apps
    as
    (
        SELECT samples.id as id, samples.device_id as device_id, battery_level, app_processes.created_at as d
        FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
        WHERE name = 'com.android.chrome' and importance='Foreground app'
    
    
    
    
    
     LIMIT 20)
SELECT T1.id,
    T1.device_id as device_id,
    T1.battery_level as battery_level,
    T1.d as TimeStarted,
    MIN(T2.d) AS Date2,
    TIME_TO_SEC(TIMEDIFF(T1.d, MIN(T2.d))) AS DaysDiff
FROM apps T1
    LEFT JOIN apps T2
    ON T1.device_id = T2.device_id
        AND T2.d > T1.d
GROUP BY T1.device_id, T1.d
),
t2 as
(
    select TimeStarted, Date2, device_id
from t1
where t1.DaysDiff < -40
)
,
t3 as
(
    select *
FROM t1
    INNER JOIN t2 on t1.TimeStarted BETWEEN t2.TimeStarted and t2.Date2
where t1.device_id = t2.device_id
group by t1.TimeStarted)
select *
from t3
group by device_id



with t1
as
(
with
    apps
    as
    (
        SELECT samples.id as id, samples.device_id as device_id, battery_level, app_processes.created_at as d
        FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
        WHERE name = 'com.android.chrome' and importance='Foreground app'
    
    
    
    
    
     LIMIT 20)
SELECT T1.id,
    T1.device_id as device_id,
    T1.battery_level as battery_level,
    T1.d as TimeStarted,
    MIN(T2.d) AS Date2,
    TIME_TO_SEC(TIMEDIFF(T1.d, MIN(T2.d))) AS DaysDiff
FROM apps T1
    LEFT JOIN apps T2
    ON T1.device_id = T2.device_id
        AND T2.d > T1.d
GROUP BY T1.device_id, T1.d
),
t2 as
(
    select TimeStarted, (Date2 - INTERVAL
1 SECOND) as Date2, device_id
    from t1
    where t1.DaysDiff < -40
)
select t1.device_id, count(*) - 1, GROUP_CONCAT(battery_level)
FROM t1
    INNER JOIN t2 on t1.TimeStarted BETWEEN t2.TimeStarted and t2.Date2
where t1.device_id = t2.device_id
group by t1.device_id;


with t1 as(
with
    apps
    as
    (
        SELECT samples.id as id, samples.device_id as device_id, battery_level, app_processes.created_at as d
        FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
        WHERE name = 'com.android.chrome' and importance='Foreground app'
    
    
    
    
    
     LIMIT 20)
SELECT T1.id,
    T1.device_id as device_id,
    T1.battery_level as battery_level,
    T1.d as TimeStarted,
    MIN(T2.d) AS Date2,
    TIME_TO_SEC(TIMEDIFF(T1.d, MIN(T2.d))) AS DaysDiff
FROM apps T1
    LEFT JOIN apps T2
    ON T1.device_id = T2.device_id
        AND T2.d > T1.d
GROUP BY T1.device_id, T1.d
),
t2 as
(
    select TimeStarted, (Date2 - INTERVAL
1 SECOND) as Date2, device_id
    from t1
    where t1.DaysDiff < -40
)
select *
FROM t1
    INNER JOIN t2 on t1.TimeStarted BETWEEN t2.TimeStarted and t2.Date2
where t1.device_id = t2.device_id








with t1 as(
with
    apps
    as
    (
        SELECT samples.id as id, samples.device_id as device_id, battery_level, app_processes.created_at as d
        FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
        WHERE name = 'com.android.chrome' and importance='Foreground app'
    
    
    
    
    
     LIMIT 20)
SELECT T1.id,
    T1.device_id as device_id,
    T1.battery_level as battery_level,
    T1.d as TimeStarted,
    MIN(T2.d) AS Date2,
    TIME_TO_SEC(TIMEDIFF(T1.d, MIN(T2.d))) AS DaysDiff
FROM apps T1
    LEFT JOIN apps T2
    ON T1.device_id = T2.device_id
        AND T2.d > T1.d
GROUP BY T1.device_id, T1.d
)
select TimeStarted, Date2 - INTERVAL
1 SECOND, device_id
from t1
where t1.DaysDiff < -40





select device_id, count(*) - 1, GROUP_CONCAT(battery_level)
from t3
group by device_id, TimeStarted


select *
from t1 join t2 ON
t1.device_id = t2.device_id
where t1.TimeStarted < t2.Date2
    and t1.TimeStarted >= t2.Date2
group by t1.device_id;

-- select t1.device_id, count(*) - 1, GROUP_CONCAT(t1.battery_level)





-- daysdiff marks the starting points
with
    apps
    as
    (
        SELECT samples.id as id, samples.device_id as device_id, battery_level, app_processes.created_at as d
        FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
        WHERE name = 'com.android.chrome' and importance='Foreground app'
    
    
    
    
    
     LIMIT 20),
t_start as
(
    SELECT T1.id,
    T1.device_id as device_id,
    T1.battery_level as battery_level,
    T1.d as d,
    MAX(T2.d) AS Date2,
    IFNULL(TIME_TO_SEC(TIMEDIFF(T1.d, Max(T2.d))),5000) AS DaysDiff
FROM apps T1
    LEFT JOIN apps T2
    ON T1.device_id = T2.device_id
        AND T2.d < T1.d
GROUP BY T1.device_id, T1.d
)
,
t_end as
(
    SELECT T1.id,
    T1.device_id as device_id,
    T1.battery_level as battery_level,
    T1.d as d,
    MIN(T2.d) AS Date2
FROM apps T1
    LEFT JOIN apps T2
    ON T1.device_id = T2.device_id
        AND T2.d > T1.d
GROUP BY T1.device_id, T1.d
)
SELECT T1.id,
    T1.device_id as device_id,
    T1.battery_level as battery_level,
    T1.d as TimeStarted,
    MIN(T2.d) AS Date2
FROM t_start T1
    LEFT JOIN t_end T2
    ON T1.device_id = T2.device_id
        AND T2.d > T1.d
GROUP BY T1.device_id, T1.d



select *
from t_end
where DaysDiff < -40


select *
from t_start
where DaysDiff > 40




select TimeStarted, Date2 - INTERVAL
1 SECOND, device_id
from t_start
where DaysDiff > -40



with
    apps
    as
    (
        SELECT samples.id as id, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
        FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
        WHERE name in('com.android.chrome','com.microsoft.emmx','com.brave.browser') and importance='Foreground app' and battery_state='Discharging'
    
    
    
    
    
     LIMIT 10000),
t_start as
(
    select *
from (
    SELECT T1.id,
        T1.device_id as device_id,
        T1.battery_level as battery_level,
        T1.d as d,
        MAX(T2.d) AS Date2,
        IFNULL(TIME_TO_SEC(TIMEDIFF(T1.d, Max(T2.d))),5000) AS DaysDiff
    FROM apps T1
        LEFT JOIN apps T2
        ON T1.device_id = T2.device_id
            AND T2.d < T1.d
    GROUP BY T1.device_id, T1.d
    ) as x
where x.DaysDiff > 40
)
,
t_end as
(
    select *
from (SELECT T1.id,
        T1.device_id as device_id,
        T1.battery_level as battery_level,
        T1.d as d,
        MIN(T2.d) AS Date2,
        IFNULL(TIME_TO_SEC(TIMEDIFF(T1.d, MIN(T2.d))),-5000) AS DaysDiff
    FROM apps T1
        LEFT JOIN apps T2
        ON T1.device_id = T2.device_id
            AND T2.d > T1.d
    GROUP BY T1.device_id, T1.d) as x
where x.DaysDiff < -40
)
,
t_boundaries as
(
    SELECT
    T1.device_id as device_id,
    T1.d as t1,
    MIN(T2.d) AS t2
FROM t_start T1
    LEFT JOIN t_end T2
    ON T1.device_id = T2.device_id
        AND T2.d >= T1.d
GROUP BY T1.device_id, T1.d
)
select
    model,
    name,
    sum(count) as num_samples,
    sum(total_discharge) / sum(DaysDiff) as avg_discharge
FROM (
    select model,
        count,
        (max - min) as total_discharge,
        DaysDiff,
        name
    FROM (
    select t1.device_id as device_id,
            count(*) as count,
            model,
            name,
            MAX(battery_level) as max,
            min(battery_level) as min,
            GROUP_CONCAT(battery_level),
            TIME_TO_SEC(TIMEDIFF(t_boundaries.t2,t_boundaries.t1)) AS DaysDiff
        FROM apps t1
            INNER JOIN t_boundaries on t1.d BETWEEN t_boundaries.t1 and t_boundaries.t2
        where t1.device_id = t_boundaries.device_id
        group by t_boundaries.t1
    ) as x
    where x.DaysDiff<>0
) as y
group by y.model, y.name;



DROP TABLE IF EXISTS result;
CREATE TABLE result(model TEXT(65535), name TEXT(65535), num_samples int, avg_discharge FLOAT);
Insert ignore into result SELECT model, name,num_samples,avg_discharge from (
    with apps as (
        (SELECT samples.id as id, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
        FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
        WHERE name = 'com.microsoft.emmx' and importance='Foreground app' and battery_state='Discharging' limit 5000)
    UNION ALL
    (SELECT samples.id as id, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
    WHERE name = 'com.brave.browser' and importance='Foreground app' and battery_state='Discharging' limit 5000)
    UNION ALL
    (SELECT samples.id as id, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
    WHERE name = 'com.android.chrome' and importance='Foreground app' and battery_state='Discharging' limit 5000)
    UNION ALL
    (SELECT samples.id as id, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
    WHERE name = 'com.opera.browser' and importance='Foreground app' and battery_state='Discharging' limit 5000)
    UNION ALL
    (SELECT samples.id as id, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
    WHERE name = 'org.mozilla.firefox' and importance='Foreground app' and battery_state='Discharging' limit 5000)
),
t_start as (
    select *
from (
    SELECT T1.id,
        T1.device_id as device_id,
        T1.battery_level as battery_level,
        T1.d as d,
        MAX(T2.d) AS Date2,
        IFNULL(TIME_TO_SEC(TIMEDIFF(T1.d, Max(T2.d))),5000) AS DaysDiff
    FROM apps T1
        LEFT JOIN apps T2
        ON T1.device_id = T2.device_id
            AND T2.d < T1.d
    GROUP BY T1.device_id, T1.d
    ) as x
where x.DaysDiff > 40
),
t_end as (
    select *
from (SELECT T1.id,
        T1.device_id as device_id,
        T1.battery_level as battery_level,
        T1.d as d,
        MIN(T2.d) AS Date2,
        IFNULL(TIME_TO_SEC(TIMEDIFF(T1.d, MIN(T2.d))),-5000) AS DaysDiff
    FROM apps T1
        LEFT JOIN apps T2
        ON T1.device_id = T2.device_id
            AND T2.d > T1.d
    GROUP BY T1.device_id, T1.d) as x
where x.DaysDiff < -40
),
t_boundaries as (
    SELECT
    T1.device_id as device_id,
    T1.d as t1,
    MIN(T2.d) AS t2
FROM t_start T1
    LEFT JOIN t_end T2
    ON T1.device_id = T2.device_id
        AND T2.d >= T1.d
GROUP BY T1.device_id, T1.d
)
select
    model,
    name,
    sum(count) as num_samples,
    sum(total_discharge) / sum(DaysDiff) as avg_discharge
FROM (
        select model,
        count,
        (max - min) as total_discharge,
        DaysDiff,
        name
    FROM (
        select t1.device_id as device_id,
            count(*) as count,
            model,
            name,
            MAX(battery_level) as max,
            min(battery_level) as min,
            GROUP_CONCAT(battery_level),
            TIME_TO_SEC(TIMEDIFF(t_boundaries.t2,t_boundaries.t1)) AS DaysDiff
        FROM apps t1
            INNER JOIN t_boundaries on t1.d BETWEEN t_boundaries.t1 and t_boundaries.t2
        where t1.device_id = t_boundaries.device_id
        group by t_boundaries.t1
        ) as x
    where x.DaysDiff<>0
    ) as y
group by y.model, y.name;
SET @sql = NULL;
SET @sql2 = NULL;
DROP TABLE IF EXISTS result2;

SELECT
  GROUP_CONCAT(DISTINCT
   CONCAT("`",name,"` TEXT(65535)")
 )
 INTO @sql2
FROM result;
SET @sql2 = CONCAT('CREATE TABLE result2(model TEXT(65535), ', @sql2,')');
PREPARE stmt FROM @sql2;
EXECUTE stmt;

SELECT
  GROUP_CONCAT(DISTINCT
     CONCAT(
       'MAX(IF(name = ''',
   name,
   ''', avg_discharge, NULL)) AS ',
   CONCAT("'",name,"'")
 )
   ) INTO @sql
FROM result;

SET @sql = CONCAT('Insert ignore into result2 SELECT model, ', @sql, ' FROM result GROUP BY model');

PREPARE stmt FROM @sql;
EXECUTE stmt;













select model, text,num_samples,avg_discharge
into result
FROM results


insert into result(model, name, num_samples, avg_discharge)
SELECT model, text,num_samples,avg_discharge from results;

CREATE TABLE result(model TEXT, name TEXT, num_samples int, avg_discharge FLOAT) SELECT model, text,num_samples,avg_discharge from results;


SELECT
  GROUP_CONCAT(DISTINCT
     CONCAT(
       'MAX(IF(name = ''',
   name,
   ''', total_discharge, NULL)) AS ',
   CONCAT("'",name,"'")
 )
   ) INTO @sql
FROM results;

SET @sql = CONCAT('SELECT model, ', @sql, ' FROM results GROUP BY model');

PREPARE stmt FROM @sql;
EXECUTE stmt;




select * from results;

CREATE TABLE result(model TEXT, name TEXT, num_samples int, avg_discharge FLOAT) SELECT model, text,num_samples,avg_discharge from results;


CALL Pivot('results', 'model', 'name', 'avg_discharge', '', '');


select model,
    max(case when seqnum = 1 then name end) as name_01,
    max(case when seqnum = 2 then name end) as name_02,
    max(case when seqnum = 3 then name end) as name_03, 
from (select results.*,
        row_number() over (partition by model order by name) as seqnum
    from table results
     ) t
group by model;







SELECT
    samples.id as id, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
FROM
    (
    SELECT
        X.*,
        IF(@sameClass = class_id, @rn := @rn + 1,
        IF(@sameClass := class_id, @rn := 1, @rn := 1)
        ) AS rank
    FROM    table_x AS X
    CROSS JOIN (SELECT @sameClass := 0, @rn := 1 ) AS var
WHERE name IN (1, 2, 3)
ORDER BY class_id, time_x DESC
) AS t
WHERE t.rank <= 15
ORDER BY t.class_id, t.rank

SELECT samples.id as id, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
WHERE name = 'com.android.chrome' and importance='Foreground app' and battery_state='Discharging' and samples.timestamp > '2018-01-01'
LIMIT 20


select chain,
    max(case when seqnum = 1 then branch end) as branch_01,
    max(case when seqnum = 2 then branch end) as branch_02,
    max(case when seqnum = 3 then branch end) as branch_03,
    max(case when seqnum = 4 then branch end) as branch_04
from (select t.*,
        row_number() over (partition by chain order by branch) as seqnum
    from table t
     ) t
group by chain;

(select *

FROM(

select model,
        count,
        (max - min) as total_discharge
    DaysDiff
FROM
(
select t1.device_id as device_id,
    count(*) as count,
    model,
    MAX(battery_level) as max,
    min(battery_level) as min,
    GROUP_CONCAT(battery_level),
    TIME_TO_SEC(TIMEDIFF(t_boundaries.t2,t_boundaries.t1)) AS DaysDiff
FROM apps t1
    INNER JOIN t_boundaries on t1.d BETWEEN t_boundaries.t1 and t_boundaries.t2
where t1.device_id = t_boundaries.device_id
group by t_boundaries.t1
)
as x
where x.DaysDiff<>0)
group by model) as y
group by model,





SELECT battery_details.*
FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON samples.id = battery_details.sample_id
WHERE name = 'com.android.chrome' and importance='Foreground app' and battery_state='Discharging'
LIMIT 20