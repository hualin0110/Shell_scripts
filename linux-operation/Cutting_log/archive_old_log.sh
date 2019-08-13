#!/bin/bash
# Time : 2019/8/13
# Author : "郁唯"

#!/bin/bash
# Time : 2019/8/13
# Author : "郁唯"

#If you want to use in linux by crontab ,please write the below line to /var/spool/cron/root
#1 0 * * * /bin/bash /usr/local/zqsign-web-wesign/bin/cut_tomcat_log.sh /usr/local/zqsign-web-wesign/logs  >>/root/huaxuelin/cut_web-wesign.log  2>&1 &

yestday_date=$(date -d "-1 day" +%Y-%m-%d)
today_date=$(date  +%Y-%m-%d)
IN_Face=`route -n |awk '{if($4~/UG/){print $8}}'|head -n 1`
host_ip=`ip a|grep -B1 -C1 -w "${IN_Face}"|grep -w 'inet'|awk '{print $2}'|awk -F\/ '{print $1}'|head -n 1`
#指定obsutil运行的文件
obsutil_dir="/usr/local/obsutil/obsutil_linux_amd64_5.1.6"
obsutilrun="/usr/local/obsutil/obsutil_linux_amd64_5.1.6/obsutil"

function check_obsutil() {
    if [[ ! -d $obsutil_dir ]]; then
        rsync -aP -e "ssh -o StrictHostKeyChecking=no" root@192.168.0.43:/soft/obsutil /usr/local/
    fi
    $obsutilrun config -i=TOBCIBDX37P9SEUXGXQ2 -k=UxFpCki8KfvxS6A5gjVFbmNoieHmyFJ8g62roS5W -e=https://obs.cn-north-1.myhuaweicloud.com
}

##获取运行中的tomcat的目录
function get_tomcat_dir() {
    echo $(ps -ef |grep java |grep -E -v "grep|CloudResetPwdUpdateAgent"|awk '/Dcatalina.base/{for(i=1;i<=NF;i++)if($i ~ /Dcatalina.base/) print $i}'|awk -F '=' '{ print $2 }')
}

function archive_to_obs() {
    #检查obs中是否有相应项目在某个主机中的日志，按照天的维度进行存储
    yestday_obs_dir="obs://collect-logs-for-zqservice/${Tomcat_dir##*/}/$host_ip/$yestday_date/"
    check_obsdir=$($obsutilrun stat $yestday_obs_dir|grep Error|grep 404|wc -l)
    if [[ $check_obsdir -ne 0 ]]; then
        $obsutilrun mkdir $yestday_obs_dir
    fi

    #进入项目日志目录，将归档后的catalina.out日志上传到obs中
    cd $Tomcat_dir/logs/
    for filename in $(ls catalina.2*.out server.2*.zip server.log_2*log);do
        $obsutilrun cp $filename $yestday_obs_dir
    done
}

###Start run archive the tocmat's log
echo "Starting archive the logs"
#检查obsutil是否安装
check_obsutil

#进行日志的归档以及
for Tomcat_dir in $(get_tomcat_dir);do
    echo $Tomcat_dir
    echo ${Tomcat_dir##*/}
    archive_to_obs
done


