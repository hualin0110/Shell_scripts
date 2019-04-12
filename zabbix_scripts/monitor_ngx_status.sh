#!/usr/bin/env bash
#Author: "郁唯"
#Time: 2019/4/12
#zabbix监控nginx性能以及进程状态
#此脚本需要安装在被监控端

Host_ip="127.0.0.1"
Host_port="80"



#检测nginx 进程是否存在
nginx_ping(){
    /bin/pidof nginx |wc -l
}

#检测nginx性能
active(){
    /usr/bin/curl "http://$Host_ip:$Host_port/ngx_status/" 2>/dev/null |grep "Active"|awk '{ print $NF }'
}
reading(){
    /usr/bin/curl "http://$Host_ip:$Host_port/ngx_status/" 2>/dev/null |grep "Reading"|awk '{ print $2 }'
}
writing(){
    /usr/bin/curl "http://$Host_ip:$Host_port/ngx_status/" 2>/dev/null |grep "Writing"|awk '{ print $4 }'
}
waiting(){
    /usr/bin/curl "http://$Host_ip:$Host_port/ngx_status/" 2>/dev/null |grep "Waiting"|awk '{ print $6 }'
}
accepts(){
    /usr/bin/curl "http://$Host_ip:$Host_port/ngx_status/" 2>/dev/null |awk NR==3|awk '{ print $1 }'
}
handled(){
    /usr/bin/curl "http://$Host_ip:$Host_port/ngx_status/" 2>/dev/null |awk NR==3|awk '{ print $2 }'
}
requests(){
    /usr/bin/curl "http://$Host_ip:$Host_port/ngx_status/" 2>/dev/null |awk NR==3|awk '{ print $3 }'
}

#执行函数
$1