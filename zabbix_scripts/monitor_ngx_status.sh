#!/usr/bin/env bash
#Author: "郁唯"
#Time: 2019/4/12
#zabbix监控nginx性能以及进程状态
#此脚本需要安装在被监控端

:<<EOF
需要在zabbix客户端配置以下内容：
需要将此monitor_ngx_status.sh存放到zabbix目录的scripts目录下，并且可能需要赋予此脚本zabbix用户的权限;
#cat /usr/local/zabbix/etc/zabbix_agentd.conf | grep nginx
UserParameter=nginx.status[*],/usr/local/zabbix/scripts/monitor_ngx-status.sh $1
# killall zabbix_agentd
# /usr/local/zabbix-3.0.0/sbin/zabbix_agentd
EOF


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