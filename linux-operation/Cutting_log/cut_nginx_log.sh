#!/usr/bin/env bash
# Time : 2019/4/3
# Author : "郁唯"
#Rotate the Nginx logs to prevent a single logfile from consuming too much disk space.
LOGS_PATH=/usr/local/nginx/logs
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)

mv ${LOGS_PATH}/access.log ${LOGS_PATH}/access_${YESTERDAY}.log
mv ${LOGS_PATH}/error.log ${LOGS_PATH}/error_${YESTERDAY}.log
## 向 Nginx 主进程发送 USR1 信号。USR1 信号是重新打开日志文件
kill -USR1 $(cat /usr/local/nginx/logs/nginx.pid)
##压缩日志

tar -zcPf ${LOGS_PATH}/access_${YESTERDAY}.log.tar.gz ${LOGS_PATH}/access_${YESTERDAY}.log --remove-files
tar -zcPf ${LOGS_PATH}/error_${YESTERDAY}.log.tar.gz ${LOGS_PATH}/error_${YESTERDAY}.log --remove-files
