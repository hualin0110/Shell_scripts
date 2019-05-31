#!/usr/bin/python3
# -*- coding: UTF-8 -*-
import os
import subprocess
import simplejson as json

TOMCAT_HOME="/usr/local/tomcat/"

#TOMCAT_NAME="/bin/find 'TOMCAT_HOME' -name 'server.xml' | sort -n | uniq -c | awk -F'/' '{print $4}'"
#TOMCAT_NAME="/bin/find /usr/local/tomcat/ -name 'server.xml' | sort -n | uniq -c | awk -F'/' '{print $5}'"
##两种检测tomcat的方式，下面这个，如果是tomcat的目录下的项目的话，用下面这个，如果，直接在/usr/local下面直接就是项目，那就用现在打开的这个吧，pycharm 这个本地调试需要禁用
#TOMCAT_NAME="ps -ef |grep java|grep tomcat|grep -v grep|grep -v pycharm |awk '{ print $9 }'|awk -F '/' '{ print $(NF-2) }'"
TOMCAT_NAME="ps -ef |grep java|grep -v grep|grep -v pycharm |awk '{ print $9 }'|awk -F '/' '{ print $(NF-2) }'"

t=subprocess.getoutput(TOMCAT_NAME)
tomcats=[]
for tomcat in t.split('\n'):
    if len(tomcat) != 0:
        tomcats.append({'{#TOMCAT_NAME}':tomcat})
# # 打印出zabbix可识别的json格式
print(json.dumps({'data':tomcats},sort_keys=True,indent=4,separators=(',',':')))