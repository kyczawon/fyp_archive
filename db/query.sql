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
    sum(total_discharge) / sum(TimeDiff) as avg_discharge
FROM (
        select model,
        count,
        (max - min) as total_discharge,
        TimeDiff,
        name
    FROM (
        select t1.device_id as device_id,
            count(*) as count,
            model,
            name,
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
    sum(total_discharge) / sum(TimeDiff) as avg_discharge
FROM (
        select model,
        count,
        (max - min) as total_discharge,
        TimeDiff,
        name
    FROM (
        select t1.device_id as device_id,
            count(*) as count,
            model,
            name,
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

SET @sql = CONCAT('SELECT model, ', @sql, ' FROM result GROUP BY model');

PREPARE stmt FROM @sql;
EXECUTE stmt;