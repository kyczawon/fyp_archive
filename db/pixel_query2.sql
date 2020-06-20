
Insert ignore into results1M SELECT * from (
with apps as (
    SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name in ('com.microsoft.emmx', 'com.brave.browser', 'com.android.chrome', 'com.opera.browser', 'org.mozilla.firefox') and battery_state='Discharging' limit 1000000
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
    MIN(T2.d) AS t2, 
    TIME_TO_SEC(TIMEDIFF(T2.d, T1.d)) as time_diff
FROM t_start T1
    LEFT JOIN t_end T2
    ON T1.device_id = T2.device_id
        AND T2.d >= T1.d
GROUP BY T1.device_id, T1.d
HAVING time_diff > 10
)
select
    model,
    name,
    importance,
    sum(count) as num_samples,
    sum(total_discharge) / sum(TimeDiff) as avg_discharge,
    sum(total_discharge) / sum(TimeDiff) * capacity * 3.6 / sum(TimeDiff) * AVG(voltage) as avg_power,
    AVG(voltage) * AVG(current_now) / -1000 as avg_power2

    FROM (
        select t1.device_id as device_id,
            count(*) as count,
            model,
            capacity,
            name,
            voltage,
            current_now,
            importance,
            (MAX(battery_level) - min(battery_level)) as total_discharge,
            MAX(battery_level) as max,
            min(battery_level) as min,
            GROUP_CONCAT(battery_level),
            TIME_TO_SEC(TIMEDIFF(t_boundaries.t2,t_boundaries.t1)) AS TimeDiff
        FROM apps t1
            INNER JOIN t_boundaries on t1.d BETWEEN t_boundaries.t1 and t_boundaries.t2
        where t1.device_id = t_boundaries.device_id
        and current_now < 0
        group by t_boundaries.t1
        having TimeDiff<>0
    ) as y
where y.total_discharge > 0
group by y.model, y.name, y.importance) as t;

-- reddit query
insert ignore into results1M SELECT * from (
with apps as (
    SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name in ('com.microsoft.emmx', 'com.brave.browser', 'com.android.chrome', 'com.opera.browser', 'org.mozilla.firefox') and battery_state='Discharging' limit 1000000
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
    MIN(T2.d) AS t2, 
    TIME_TO_SEC(TIMEDIFF(T2.d, T1.d)) as time_diff
FROM t_start T1
    LEFT JOIN t_end T2
    ON T1.device_id = T2.device_id
        AND T2.d >= T1.d
GROUP BY T1.device_id, T1.d
HAVING time_diff > 10
)
select
    model,
    name,
    importance,
    sum(count) as num_samples,
    sum(total_discharge) / sum(TimeDiff) as avg_discharge,
    sum(total_discharge) / sum(TimeDiff) * capacity * 3.6 / sum(TimeDiff) * AVG(voltage) as avg_power,
    AVG(voltage) * AVG(current_now) / -1000 as avg_power2

    FROM (
        select t1.device_id as device_id,
            count(*) as count,
            model,
            capacity,
            name,
            voltage,
            current_now,
            importance,
            (MAX(battery_level) - min(battery_level)) as total_discharge,
            MAX(battery_level) as max,
            min(battery_level) as min,
            GROUP_CONCAT(battery_level),
            TIME_TO_SEC(TIMEDIFF(t_boundaries.t2,t_boundaries.t1)) AS TimeDiff
        FROM apps t1
            INNER JOIN t_boundaries on t1.d BETWEEN t_boundaries.t1 and t_boundaries.t2
        where t1.device_id = t_boundaries.device_id
        and current_now < 0
        group by t_boundaries.t1
        having TimeDiff<>0
    ) as y
where y.total_discharge > 0
group by y.model, y.name, y.importance) as t;


-- 1m all query
Insert ignore into results1M_full SELECT * from (
with apps as (
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='com.microsoft.emmx' and battery_state='Discharging' limit 1000000)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='com.brave.browser' and battery_state='Discharging' limit 1000000)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='com.android.chrome' and battery_state='Discharging' limit 1000000)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='com.opera.browser' and battery_state='Discharging' limit 1000000)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='org.mozilla.firefox' and battery_state='Discharging' limit 1000000)
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
    MIN(T2.d) AS t2, 
    TIME_TO_SEC(TIMEDIFF(T2.d, T1.d)) as time_diff
FROM t_start T1
    LEFT JOIN t_end T2
    ON T1.device_id = T2.device_id
        AND T2.d >= T1.d
GROUP BY T1.device_id, T1.d
HAVING time_diff > 10
)
select
    model,
    name,
    importance,
    sum(count) as num_samples,
    -- P = VI, P = V*C(columbs)/t= V*3.6*C(mAh)/t= V*3.6*(t)/t
    sum(total_discharge) / sum(TimeDiff) as avg_discharge,
    sum(total_discharge) / sum(TimeDiff) * capacity * 3.6 / sum(TimeDiff) * AVG(voltage) as avg_power,
    AVG(voltage) * AVG(current_now) / -1000 as avg_power2

    FROM (
        select t1.device_id as device_id,
            count(*) as count,
            model,
            capacity,
            name,
            voltage,
            current_now,
            importance,
            (MAX(battery_level) - min(battery_level)) as total_discharge,
            MAX(battery_level) as max,
            min(battery_level) as min,
            GROUP_CONCAT(battery_level),
            TIME_TO_SEC(TIMEDIFF(t_boundaries.t2,t_boundaries.t1)) AS TimeDiff
        FROM apps t1
            INNER JOIN t_boundaries on t1.d BETWEEN t_boundaries.t1 and t_boundaries.t2
        where t1.device_id = t_boundaries.device_id
        and current_now < 0
        group by t_boundaries.t1
        having TimeDiff<>0
    ) as y
where y.total_discharge > 0
group by y.model, y.name, y.importance) as t;

-- reddit query
Insert ignore into results_reddit2 SELECT * from (
with apps as (
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='com.andrewshu.android.reddit' and battery_state='Discharging' limit 10)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='com.onelouder.baconreader' and battery_state='Discharging' limit 437)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='com.reddit.frontpage' and battery_state='Discharging' limit 26098)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='free.reddit.news' and battery_state='Discharging' limit 1)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='org.quantumbadger.redreader' and battery_state='Discharging' limit 2)
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
    MIN(T2.d) AS t2, 
    TIME_TO_SEC(TIMEDIFF(T2.d, T1.d)) as time_diff
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
    avg(TimeDiff) as avg_time_diff,
    -- P = VI, P = V*C(columbs)/t= V*3.6*C(mAh)/t= V*3.6*(t)/t
    sum(total_discharge) / sum(TimeDiff) as avg_discharge,
    sum(total_discharge) / sum(TimeDiff) * capacity * 3.6 / sum(TimeDiff) * AVG(voltage) as avg_power,
    AVG(voltage) * AVG(current_now) / -1000 as avg_power2

    FROM (
        select t1.device_id as device_id,
            count(*) as count,
            model,
            capacity,
            name,
            voltage,
            current_now,
            importance,
            (MAX(battery_level) - min(battery_level)) as total_discharge,
            MAX(battery_level) as max,
            min(battery_level) as min,
            GROUP_CONCAT(battery_level),
            TIME_TO_SEC(TIMEDIFF(t_boundaries.t2,t_boundaries.t1)) AS TimeDiff
        FROM apps t1
            INNER JOIN t_boundaries on t1.d BETWEEN t_boundaries.t1 and t_boundaries.t2
        where t1.device_id = t_boundaries.device_id
        and current_now < 0
        group by t_boundaries.t1
        having TimeDiff<>0
    ) as y
where y.total_discharge > 0
group by y.model, y.name, y.importance) as t;



Insert ignore into results100k_full SELECT * from (
with apps as (
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='com.microsoft.emmx' and battery_state='Discharging' and importance='Foreground app' limit 100000)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='com.brave.browser' and battery_state='Discharging' and importance='Foreground app' limit 100000)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='com.android.chrome' and battery_state='Discharging'  and importance='Foreground app' limit 100000)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='com.opera.browser' and battery_state='Discharging' and importance='Foreground app' limit 100000)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='org.mozilla.firefox' and battery_state='Discharging' and importance='Foreground app' limit 100000)
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
    MIN(T2.d) AS t2, 
    TIME_TO_SEC(TIMEDIFF(T2.d, T1.d)) as time_diff
FROM t_start T1
    LEFT JOIN t_end T2
    ON T1.device_id = T2.device_id
        AND T2.d >= T1.d
GROUP BY T1.device_id, T1.d
HAVING time_diff > 10
)
select
    model,
    name,
    importance,
    sum(count) as num_samples,
    avg(TimeDiff) as avg_time_diff,
    -- P = VI, P = V*C(columbs)/t= V*3.6*C(mAh)/t= V*3.6*(t)/t
    sum(total_discharge) / sum(TimeDiff) as avg_discharge,
    sum(total_discharge) / sum(TimeDiff) * capacity * 3.6 / sum(TimeDiff) * AVG(voltage) as avg_power,
    AVG(voltage) * AVG(current_now) / -1000 as avg_power2

    FROM (
        select t1.device_id as device_id,
            count(*) as count,
            model,
            capacity,
            name,
            voltage,
            current_now,
            importance,
            (MAX(battery_level) - min(battery_level)) as total_discharge,
            MAX(battery_level) as max,
            min(battery_level) as min,
            GROUP_CONCAT(battery_level),
            TIME_TO_SEC(TIMEDIFF(t_boundaries.t2,t_boundaries.t1)) AS TimeDiff
        FROM apps t1
            INNER JOIN t_boundaries on t1.d BETWEEN t_boundaries.t1 and t_boundaries.t2
        where t1.device_id = t_boundaries.device_id
        and current_now < 0
        group by t_b    oundaries.t1
        having TimeDiff<>0
    ) as y
where y.total_discharge > 0
group by y.model, y.name, y.importance) as t;

Insert ignore into results1m SELECT * from (
with apps as (
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='com.microsoft.emmx' and battery_state='Discharging' and importance='Foreground app' limit 1000000)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='com.brave.browser' and battery_state='Discharging' and importance='Foreground app' limit 1000000)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='com.android.chrome' and battery_state='Discharging'  and importance='Foreground app' limit 1000000)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='com.opera.browser' and battery_state='Discharging' and importance='Foreground app' limit 1000000)
    UNION ALL
    (SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name ='org.mozilla.firefox' and battery_state='Discharging' and importance='Foreground app' limit 1000000)
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
    MIN(T2.d) AS t2, 
    TIME_TO_SEC(TIMEDIFF(T2.d, T1.d)) as time_diff
FROM t_start T1
    LEFT JOIN t_end T2
    ON T1.device_id = T2.device_id
        AND T2.d >= T1.d
GROUP BY T1.device_id, T1.d
HAVING time_diff > 10
)
select
    model,
    name,
    importance,
    sum(count) as num_samples,
    avg(TimeDiff) as avg_time_diff,
    -- P = VI, P = V*C(columbs)/t= V*3.6*C(mAh)/t= V*3.6*(t)/t
    sum(total_discharge) / sum(TimeDiff) as avg_discharge,
    sum(total_discharge) / sum(TimeDiff) * capacity * 3.6 / sum(TimeDiff) * AVG(voltage) as avg_power,
    AVG(voltage) * AVG(current_now) / -1000 as avg_power2

    FROM (
        select t1.device_id as device_id,
            count(*) as count,
            model,
            capacity,
            name,
            voltage,
            current_now,
            importance,
            (MAX(battery_level) - min(battery_level)) as total_discharge,
            MAX(battery_level) as max,
            min(battery_level) as min,
            GROUP_CONCAT(battery_level),
            TIME_TO_SEC(TIMEDIFF(t_boundaries.t2,t_boundaries.t1)) AS TimeDiff
        FROM apps t1
            INNER JOIN t_boundaries on t1.d BETWEEN t_boundaries.t1 and t_boundaries.t2
        where t1.device_id = t_boundaries.device_id
        and current_now < 0
        group by t_boundaries.t1
        having TimeDiff<>0
    ) as y
where y.total_discharge > 0
group by y.model, y.name, y.importance) as t;

-- pixel query
Insert ignore into results1M_full_foreground SELECT * from (
with apps as (
    SELECT samples.id as id, importance, battery_details.voltage as voltage, current_now, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name in ('com.microsoft.emmx', 'com.brave.browser', 'com.android.chrome', 'com.opera.browser', 'org.mozilla.firefox') and battery_state='Discharging' and model LIKE 'Pixel%'
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
    MIN(T2.d) AS t2, 
    TIME_TO_SEC(TIMEDIFF(T2.d, T1.d)) as time_diff
FROM t_start T1
    LEFT JOIN t_end T2
    ON T1.device_id = T2.device_id
        AND T2.d >= T1.d
GROUP BY T1.device_id, T1.d
HAVING time_diff > 10
)
select
    model,
    name,
    importance,
    sum(count) as num_samples,
    -- P = VI, P = V*C(columbs)/t= V*3.6*C(mAh)/t= V*3.6*(t)/t
    avg(TimeDiff) as avg_time_diff,
    sum(total_discharge) / sum(TimeDiff) as avg_discharge,
    sum(total_discharge) / sum(TimeDiff) * capacity * 3.6 / sum(TimeDiff) * AVG(voltage) as avg_power,
    AVG(voltage) * AVG(current_now) / -1000 as avg_power2

    FROM (
        select t1.device_id as device_id,
            count(*) as count,
            model,
            capacity,
            name,
            voltage,
            current_now,
            importance,
            (MAX(battery_level) - min(battery_level)) as total_discharge,
            MAX(battery_level) as max,
            min(battery_level) as min,
            GROUP_CONCAT(battery_level),
            TIME_TO_SEC(TIMEDIFF(t_boundaries.t2,t_boundaries.t1)) AS TimeDiff
        FROM apps t1
            INNER JOIN t_boundaries on t1.d BETWEEN t_boundaries.t1 and t_boundaries.t2
        where t1.device_id = t_boundaries.device_id
        and current_now < 0
        group by t_boundaries.t1
        having TimeDiff<>0
    ) as y
where y.total_discharge > 0
group by y.model, y.name, y.importance) as t;



SELECT count(*)
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name in ('com.microsoft.emmx', 'com.brave.browser', 'com.android.chrome', 'com.opera.browser', 'org.mozilla.firefox') and battery_state='Discharging' and model LIKE 'Pixel%'


SELECT count(*)
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
    WHERE name = 'org.mozilla.firefox' and battery_state='Discharging' and model LIKE 'Pixel%'


SELECT count(*)
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
    WHERE name in ('com.andrewshu.android.reddit', 'com.onelouder.baconreader', 'com.reddit.frontpage', 'free.reddit.news', 'org.quantumbadger.redreader') and battery_state='Discharging'


'com.microsoft.emmx', 'com.brave.browser', 'com.android.chrome', 'com.opera.browser', 'org.mozilla.firefox'

    SELECT count(*)
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
    WHERE name = 'com.android.chrome' and battery_state='Discharging' and importance='Foreground app'

SELECT count(*)
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
    WHERE name = 'com.reddit.frontpage' and battery_state='Discharging'

    

with apps as (
    SELECT samples.id as id, importance, battery_details.voltage as voltage, devices.capacity as capacity, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
    FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id JOIN battery_details ON battery_details.sample_id = samples.id 
    WHERE name in ('com.andrewshu.android.reddit', 'com.onelouder.baconreader', 'com.reddit.frontpage', 'free.reddit.news', 'org.quantumbadger.redreader') and battery_state='Discharging'
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
    MIN(T2.d) AS t2, 
    TIME_TO_SEC(TIMEDIFF(T2.d, T1.d)) as time_diff
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
where y.total_discharge > 0
group by y.model, y.name, y.importance;