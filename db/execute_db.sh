arr=()
usage() { echo "Usage: $0 [-s <45|90>] [-p <string>]" 1>&2; exit 1; }

while getopts ":l:a" o; do
    case "${o}" in
        l)
            limit=${OPTARG}
            ;;
        a)
            echo ${OPTARG}
            for i in $(echo ${OPTARG} | sed "s/,/ /g")
            do
                # call your procedure/other scripts here below
                echo "$i"
            done
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# if [ -z "${s}" ] || [ -z "${p}" ]; then
#     usage
# fi

echo "s = ${limit}"
echo "p = ${arr}"


# while getopts "d:" opt
# do
#   case ${opt} in
#     l)
#         limit=${OPTARG};;
#     # h)
#     #   echo "Query to create benchmarks"
#     #   echo " "
#     #   echo "$Query [options] application [arguments]"
#     #   echo " "
#     #   echo "options:"
#     #   echo "-h, --help                show brief help"
#     #   echo "-l, --limit=LIMIT         specify the limit in queries"
#     #   echo "-a, --arr=ARRAY         specify an array of application names to build the benchmark for"
#     #   exit 0
#     #   ;;
    
#     #   if test $# -gt 0; then
#     #     limit=$1
#     #   else
#     #     echo "no limit specified"
#     #     exit 1
#     #   fi
#     #   ;;
#     # -limit*)
#     #   limit=`echo $1 | sed -e 's/^[^=]*=//g'`
#     #   ;;
#     # *)
#     #     echo $1
#     #     arr+=($1)
#     #   ;;
#     # d) dbs+=("$OPTARG");;
#   esac
# done

# echo $arr;  


# while test $# -gt 0; do
#   case "$1" in
#     -h|--help)
#       echo "Query to create benchmarks"
#       echo " "
#       echo "$Query [options] application [arguments]"
#       echo " "
#       echo "options:"
#       echo "-h, --help                show brief help"
#       echo "-l, --limit=LIMIT         specify the limit in queries"
#       echo "-a, --arr=ARRAY         specify an array of application names to build the benchmark for"
#       exit 0
#       ;;
#     -l)
#       shift
#       if test $# -gt 0; then
#         limit=$1
#       else
#         echo "no limit specified"
#         exit 1
#       fi
#       shift
#       ;;
#     --limit*)
#       limit=`echo $1 | sed -e 's/^[^=]*=//g'`
#       shift
#       ;;
#     *)
#         echo $1
#         arr+=($1)
#         shift
#       ;;
#   esac
# done







# function join_by { local d="$1" a="$2"; shift 2; printf %s%s "$a" "${@/#/$d}"; }

# declare -a arr=("com.microsoft.emmx" "com.brave.browser" "com.android.chrome" "com.opera.browser" "org.mozilla.firefox");

# ARRAY=()
# limit=5000

# for name in "${arr[@]}"
# do
#     ARRAY+=("(SELECT samples.id as id, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
#         FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
#         WHERE name = '$name' and importance='Foreground app' and battery_state='Discharging' limit $limit)")
#    # or do whatever with individual element of the array
# done

# # SELECT samples.id as id, name, samples.device_id as device_id, battery_level, app_processes.created_at as d, model
# #         FROM app_processes JOIN samples ON app_processes.sample_id = samples.id JOIN devices ON samples.device_id = devices.id
# #         WHERE name = 'com.microsoft.emmx' and importance='Foreground app' and battery_state='Discharging' limit 5000

# QUERY=$(join_by ' UNION ALL ' "${ARRAY[@]}")
# echo $QUERY;


# x='"';
# y='`';
# MYSQL_PWD=te4ejafu! mysql -u leszek@lesz -h lesz.mariadb.database.azure.com -e "use fyp; DROP TABLE IF EXISTS result; CREATE TABLE result(model TEXT(65535), name TEXT(65535), num_samples int, avg_discharge FLOAT); Insert ignore into result SELECT model, name,num_samples,avg_discharge from ( with apps as ($QUERY), t_start as ( select * from ( SELECT T1.id, T1.device_id as device_id, T1.battery_level as battery_level, T1.d as d, MAX(T2.d) AS Date2, IFNULL(TIME_TO_SEC(TIMEDIFF(T1.d, Max(T2.d))),5000) AS DaysDiff FROM apps T1 LEFT JOIN apps T2 ON T1.device_id = T2.device_id AND T2.d < T1.d GROUP BY T1.device_id, T1.d ) as x where x.DaysDiff > 40 ), t_end as ( select * from (SELECT T1.id, T1.device_id as device_id, T1.battery_level as battery_level, T1.d as d, MIN(T2.d) AS Date2, IFNULL(TIME_TO_SEC(TIMEDIFF(T1.d, MIN(T2.d))),-5000) AS DaysDiff FROM apps T1 LEFT JOIN apps T2 ON T1.device_id = T2.device_id AND T2.d > T1.d GROUP BY T1.device_id, T1.d) as x where x.DaysDiff < -40 ), t_boundries as ( SELECT T1.device_id as device_id, T1.d as t1, MIN(T2.d) AS t2 FROM t_start T1 LEFT JOIN t_end T2 ON T1.device_id = T2.device_id AND T2.d >= T1.d GROUP BY T1.device_id, T1.d ), results as( select model, name, sum(count) as num_samples, sum(total_discharge) / sum(DaysDiff) as avg_discharge FROM ( select model, count, (max - min) as total_discharge, DaysDiff, name FROM ( select t1.device_id as device_id, count(*) as count, model, name, MAX(battery_level) as max, min(battery_level) as min, GROUP_CONCAT(battery_level), TIME_TO_SEC(TIMEDIFF(t_boundries.t2,t_boundries.t1)) AS DaysDiff FROM apps t1 INNER JOIN t_boundries on t1.d BETWEEN t_boundries.t1 and t_boundries.t2 where t1.device_id = t_boundries.device_id group by t_boundries.t1 ) as x where x.DaysDiff<>0 ) as y group by y.model, y.name ) select * from results ) as r; SET @sql = NULL; SET @sql2 = NULL; DROP TABLE IF EXISTS result2; SELECT GROUP_CONCAT(DISTINCT CONCAT(${x}${y}${x},name,${x}${y} TEXT(65535)${x}) ) INTO @sql2 FROM result; SET @sql2 = CONCAT('CREATE TABLE result2(model TEXT(65535), ', @sql2,')'); PREPARE stmt FROM @sql2; EXECUTE stmt; SELECT GROUP_CONCAT(DISTINCT CONCAT( 'MAX(IF(name = ''', name, ''', avg_discharge, NULL)) AS ', CONCAT(${x}'${x},name,${x}'${x}) ) ) INTO @sql FROM result; SET @sql = CONCAT('Insert ignore into result2 SELECT model, ', @sql, ' FROM result GROUP BY model'); PREPARE stmt FROM @sql; EXECUTE stmt;"
# php -f query.php;
# open "./file.html";