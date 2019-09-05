#!/bin/bash
# Time : 2019/8/13
# Author : "郁唯"

#If you want to use in linux by crontab ,please write the below line to /var/spool/cron/root
#1 0 * * * /bin/bash /usr/local/zqsign-web-wesign/bin/cut_tomcat_log.sh /usr/local/zqsign-web-wesign/logs  >>/root/huaxuelin/cut_web-wesign.log  2>&1 &

##系统变量加载
PATH="/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"

yestday_date=$(date -d "-1 day" +%Y-%m-%d)
today_date=$(date  +%Y-%m-%d)
IN_Face=`route -n |awk '{if($4~/UG/){print $8}}'|head -n 1`
host_ip=`ip a|grep -B1 -C1 -w "${IN_Face}"|grep -w 'inet'|awk '{print $2}'|awk -F\/ '{print $1}'|head -n 1`
#指定obsutil运行的文件
obsutil_dir="/usr/local/obsutil/obsutil_linux_amd64_5.1.6"
obsutilrun="/usr/local/obsutil/obsutil_linux_amd64_5.1.6/obsutil"
##yestday's catalina.out
yest_catalina="catalina.$yestday_date.out"


function check_obsutil() {
    if [[ ! -d $obsutil_dir ]]; then
        rsync -aP -e "ssh -o StrictHostKeyChecking=no" root@192.168.0.43:/soft/obsutil /usr/local/
    fi
    if [[ $(grep "ak=drvveuVbFS0Uz0cwTXF2jSNQO3p3NmPFlYrqonbCwCU=" /root/.obsutilconfig |wc -l) -eq 0 ]]; then
        $obsutilrun config -i=TOBCIBDX37P9SEUXGXQ2 -k=UxFpCki8KfvxS6A5gjVFbmNoieHmyFJ8g62roS5W -e=https://obs.cn-north-1.myhuaweicloud.com
    fi

}

##获取运行中的tomcat的目录
function get_tomcat_dir() {
    echo $(ps -ef |grep java |grep -E -v "grep|CloudResetPwdUpdateAgent"|awk '/Dcatalina.base/{for(i=1;i<=NF;i++)if($i ~ /Dcatalina.base/) print $i}'|awk -F '=' '{ print $2 }')
}

##切割归档日志
function archive_cut_log() {
    cd $Tomcat_dir/logs/
    /bin/cp catalina.out $yest_catalina
    ####write today to log,because huawei check log with the first line ,if first line is the same ,the log while not collect
    echo "$today_date" >catalina.out
    #打包压缩 catalina.out
    echo "tar $yest_catalina.tgz"
    /bin/tar czfP $yest_catalina.tgz $yest_catalina
    #打包压缩server.log
    echo "tar server.log_$yestday_date.log.tgz"
    /bin/tar czfP server.log_$yestday_date.log.tgz server.log_$yestday_date.log

}

function archive_to_obs() {
    #检查obs中是否有相应项目在某个主机中的日志，按照天的维度进行存储
    obs_dir="obs://collect-logs-for-zqservice/${Tomcat_dir##*/}/$host_ip/"
    check_obsdir=$($obsutilrun stat $obs_dir|grep Error|grep 404|wc -l)
    if [[ $check_obsdir -ne 0 ]]; then
        $obsutilrun mkdir $obs_dir
    fi

    #进入项目日志目录，将归档后的catalina.out日志上传到obs中
    cd $Tomcat_dir/logs/
    #上传catalina.out切割后的日志到obs中
    $obsutilrun cp $yest_catalina.tgz $obs_dir
    #将server.log切割后的日志上传到obs中
    $obsutilrun cp server.log_$yestday_date.log.tgz $obs_dir

}

function clean_old_log_file() {
    ##清理十五天之前的旧日志,如果要清理文件，请将此函数写到文件最末尾，执行文件即可。
    cd $Tomcat_dir/logs/
    find ./ -type f -mtime +15 -name "catalina*out"|xargs rm -rf
    find ./ -type f -mtime +15 -name "catalina*log"|xargs rm -rf
    find ./ -type f -mtime +15 -name "server_log*log"|xargs rm -rf
}

#检查obsutil是否安装
check_obsutil

#进行日志的归档以及
for Tomcat_dir in $(get_tomcat_dir);do
    echo $Tomcat_dir
    echo ${Tomcat_dir##*/}
    archive_cut_log
    archive_to_obs
done
