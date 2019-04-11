#!/usr/bin/env bash
# Time : 2019/4/3
# Author : "郁唯"
User="root"
Passwd="xxxxxxx"
Date=`date -d $(date -d "-180 day" +%Y%m%d) +%s`
#echo $Date $Passwd $User
$(which mysql) -u${User} -p${Passwd} -e "
use zabbix;
DELETE FROM history WHERE clock < "$Date";
optimize table history;
DELETE FROM history_str WHERE clock < $Date;
optimize table history_str;
DELETE FROM history_uint WHERE clock < $Date;
optimize table history_uint;
DELETE FROM history_text WHERE clock < $Date;
optimize table history_text;
"

#如果需要删除趋势图，将下列内容加到上面的引号中即可。
#DELETE FROM  trends WHERE 'clock' < $Date;
#optimize table  trends;
#DELETE FROM trends_uint WHERE 'clock' < $Date;
#optimize table trends_uint;
#DELETE FROM events WHERE 'clock' < $Date;
#optimize table events;
~