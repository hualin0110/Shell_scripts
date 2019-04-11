#!/usr/bin/env bash
# Time : 2019/4/3
# Author : "郁唯"
#for crontab -e is
#1 0 * * * /bin/bash /usr/local/zqsign-web-wesign/bin/cut_tomcat_log.sh /usr/local/zqsign-web-wesign/logs  >>/root/huaxuelin/cut_web-wesign.log  2>&1 &

log_path=$1
yest_day=`date -d "-1 day" +%Y-%m-%d`
today=`date  +%Y-%m-%d`
echo $yest_day

cd $log_path
/bin/cp  catalina.out catalina.$yest_day.out
###write today to log,because huawei check log with the first line ,if first line is the same ,the log while not collect
echo "$today" >catalina.out
tar czfP catalina.$yest_day.tgz catalina.$yest_day.out

find ./ -type f -mtime +30 -name "catalina*out"|xargs rm -rf
find ./ -type f -mtime +3 -name "catalina*log"|xargs rm -rf
#find ./ -type f -mtime +30 |xargs rm -rf