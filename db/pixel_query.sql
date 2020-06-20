DROP TABLE IF EXISTS result;
CREATE TABLE result(model TEXT(65535), name TEXT(65535), importance TEXT(65535), num_samples int, avg_discharge FLOAT, avg_power FLOAT);
Insert ignore into result SELECT model, capacity, name,num_samples,avg_discharge from (
    with apps as (
    (SELECT samples.id as id, battery_details.voltage as voltage, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name = 'com.microsoft.emmx' and importance='service' and battery_state='Discharging' and model LIKE 'Pixel%' limit 100)
    UNION ALL
    (
    SELECT samples.id as id, battery_details.voltage as voltage, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name = 'com.brave.browser' and importance='service' and battery_state='Discharging' and model LIKE 'Pixel%' limit 100)
    UNION ALL
    (SELECT samples.id as id, battery_details.voltage as voltage, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name = 'com.android.chrome' and importance='service' and battery_state='Discharging' and model LIKE 'Pixel%' limit 100)
    UNION ALL
    (SELECT samples.id as id, battery_details.voltage as voltage, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name = 'com.opera.browser' and importance='service' and battery_state='Discharging' and model LIKE 'Pixel%' limit 100)
    UNION ALL
    (SELECT samples.id as id, battery_details.voltage as voltage, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name = 'org.mozilla.firefox' and importance='service' and battery_state='Discharging' and model LIKE 'Pixel%' limit 100)
),
t_start as (
    select *
from (
    SELECT T1.id,
        T1.device_id as device_id,
        T1.battery_level as battery_level,
        T1.d as d,
        IFNULL(TIME_TO_SEC(TIMEDIFF(T1.d, Max(T2.d))),5000) AS TimeDiff
    FROM apps T1
        LEFT JOIN apps T2
        ON T1.device_id = T2.device_id
            AND T2.d < T1.d
    GROUP BY T1.device_id, T1.d
    ) as x
where x.TimeDiff > 40
),
t_end as (
    select *
from (SELECT T1.id,
        T1.device_id as device_id,
        T1.battery_level as battery_level,
        T1.d as d,
        IFNULL(TIME_TO_SEC(TIMEDIFF(T1.d, MIN(T2.d))),-5000) AS TimeDiff
    FROM apps T1
        LEFT JOIN apps T2
        ON T1.device_id = T2.device_id
            AND T2.d > T1.d
    GROUP BY T1.device_id, T1.d) as x
where x.TimeDiff < -40
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
    -- P = VI, P = V*C(columbs)/t= V*3.6*C(mAh)/t= V*3.6*(t)/t
    sum(total_discharge) / sum(TimeDiff) * capacity * 3.6 / sum(TimeDiff) * AVG(voltage) as avg_discharge
FROM (
        select model,
        count,
        (max - min) as total_discharge,
        TimeDiff,
        capacity,
        name,
        voltage
    FROM (
        select t1.device_id as device_id,
            count(*) as count,
            model,
            capacity,
            name,
            voltage,
            MAX(battery_level) as max,
            min(battery_level) as min,
            GROUP_CONCAT(battery_level),
            TIME_TO_SEC(TIMEDIFF(t_boundaries.t2,t_boundaries.t1)) AS TimeDiff
        FROM apps t1
            INNER JOIN t_boundaries on t1.d BETWEEN t_boundaries.t1 and t_boundaries.t2
        where t1.device_id = t_boundaries.device_id
        group by t_boundaries.t1
        ) as x
    where x.TimeDiff<>0
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






SELECT samples.id as id, battery_details.voltage as voltage, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name = 'com.android.chrome' and importance='Foreground app' and battery_state='Discharging' and model='Pixel 2' limit 100;








    SELECT samples.id as id, battery_details.voltage as voltage, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name IN ('com.android.chrome', 'com.microsoft.emmx', 'com.brave.browser', 'com.opera.browser', 'org.mozilla.firefox') and importance='Foreground app' and battery_state='Discharging' and model LIKE 'Pixel%' limit 100;






    select * from samples JOIN devices ON samples.device_id = devices.id where model='Pixel 2' limit 100;

 select * from devices  where model='Pixel 2' limit 100;







with apps as (
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name = 'com.microsoft.emmx' and battery_state='Discharging' and importance='Foreground app'
    UNION ALL
    (
    SELECT samples.id as id, importance, battery_details.voltage as voltage, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name = 'com.brave.browser' and battery_state='Discharging' and importance='Foreground app' LIMIT 10000)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name = 'com.android.chrome' and battery_state='Discharging' and importance='Foreground app' LIMIT 10000)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name = 'com.opera.browser' and battery_state='Discharging' and importance='Foreground app' LIMIT 10000)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name = 'org.mozilla.firefox' and battery_state='Discharging' and importance='Foreground app' LIMIT 10000)
),
t_start as (
    select *
from (
    SELECT T1.id,
        T1.device_id as device_id,
        T1.battery_level as battery_level,
        T1.d as d,
        IFNULL(TIME_TO_SEC(TIMEDIFF(T1.d, Max(T2.d))),5000) AS TimeDiff
    FROM apps T1
        LEFT JOIN apps T2
        ON T1.device_id = T2.device_id
            AND T2.d < T1.d
    GROUP BY T1.device_id, T1.d
    ) as x
where x.TimeDiff > 40
),
t_end as (
    select *
from (SELECT T1.id,
        T1.device_id as device_id,
        T1.battery_level as battery_level,
        T1.d as d,
        IFNULL(TIME_TO_SEC(TIMEDIFF(T1.d, MIN(T2.d))),-5000) AS TimeDiff
    FROM apps T1
        LEFT JOIN apps T2
        ON T1.device_id = T2.device_id
            AND T2.d > T1.d
    GROUP BY T1.device_id, T1.d) as x
where x.TimeDiff < -40
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
    importance,
    sum(count) as num_samples,
    -- P = VI, P = V*C(columbs)/t= V*3.6*C(mAh)/t= V*3.6*(t)/t
    sum(total_discharge) / sum(TimeDiff) as avg_discharge,
    sum(total_discharge) / sum(TimeDiff) * capacity * 3.6 / sum(TimeDiff) * AVG(voltage) as avg_power
FROM (
        select model,
        count,
        (max - min) as total_discharge,
        TimeDiff,
        capacity,
        name,
        voltage,
        importance
    FROM (
        select t1.device_id as device_id,
            count(*) as count,
            model,
            capacity,
            name,
            voltage,
            importance,
            MAX(battery_level) as max,
            min(battery_level) as min,
            GROUP_CONCAT(battery_level),
            TIME_TO_SEC(TIMEDIFF(t_boundaries.t2,t_boundaries.t1)) AS TimeDiff
        FROM apps t1
            INNER JOIN t_boundaries on t1.d BETWEEN t_boundaries.t1 and t_boundaries.t2
        where t1.device_id = t_boundaries.device_id
        group by t_boundaries.t1
        ) as x
    where x.TimeDiff<>0
    ) as y
group by y.model, y.name, y.importance
HAVING num_samples > 100;


with apps as (
    SELECT samples.id as id, importance, battery_details.voltage as voltage, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name in ('com.microsoft.emmx', 'com.brave.browser', 'com.android.chrome', 'com.opera.browser', 'org.mozilla.firefox') and battery_state='Discharging' and importance='Foreground app' limit 1000
),
t_start as (
    select *
from (
    SELECT T1.id,
        T1.device_id as device_id,
        T1.battery_level as battery_level,
        T1.d as d,
        IFNULL(TIME_TO_SEC(TIMEDIFF(T1.d, Max(T2.d))),5000) AS TimeDiff
    FROM apps T1
        LEFT JOIN apps T2
        ON T1.device_id = T2.device_id
            AND T2.d < T1.d
    GROUP BY T1.device_id, T1.d
    ) as x
where x.TimeDiff > 40
),
t_end as (
    select *
from (SELECT T1.id,
        T1.device_id as device_id,
        T1.battery_level as battery_level,
        T1.d as d,
        IFNULL(TIME_TO_SEC(TIMEDIFF(T1.d, MIN(T2.d))),-5000) AS TimeDiff
    FROM apps T1
        LEFT JOIN apps T2
        ON T1.device_id = T2.device_id
            AND T2.d > T1.d
    GROUP BY T1.device_id, T1.d) as x
where x.TimeDiff < -40
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
    importance,
    sum(count) as num_samples,
    -- P = VI, P = V*C(columbs)/t= V*3.6*C(mAh)/t= V*3.6*(t)/t
    sum(total_discharge) / sum(TimeDiff) as avg_discharge,
    sum(total_discharge) / sum(TimeDiff) * capacity * 3.6 / sum(TimeDiff) * AVG(voltage) as avg_power
FROM (
        select model,
        count,
        (max - min) as total_discharge,
        TimeDiff,
        capacity,
        name,
        voltage,
        importance
    FROM (
        select t1.device_id as device_id,
            count(*) as count,
            model,
            capacity,
            name,
            voltage,
            importance,
            MAX(battery_level) as max,
            min(battery_level) as min,
            GROUP_CONCAT(battery_level),
            TIME_TO_SEC(TIMEDIFF(t_boundaries.t2,t_boundaries.t1)) AS TimeDiff
        FROM apps t1
            INNER JOIN t_boundaries on t1.d BETWEEN t_boundaries.t1 and t_boundaries.t2
        where t1.device_id = t_boundaries.device_id
        group by t_boundaries.t1
        ) as x
    where x.TimeDiff<>0
    ) as y
group by y.model, y.name, y.importance
HAVING num_samples > 100;






