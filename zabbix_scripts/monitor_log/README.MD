如何使用监控日志的脚本
---------------
这些文件夹中都是zabbix监控日志的脚本。

##### 1、关于log_keyword*.py的说明<br>
* 如果同时监控了不同的日志的话，需要修改zabbix_monitor_log_tmp这个变量的路径。<br>
    * 检测了tomcat时，需要修改zabbix_monitor_log_tmp这个变量的路径zabbix_base +'script/tomcat/monitor_tomcatlog_line.safe<br>
    * 检测了nginx时，需要修改zabbix_monitor_log_tmp这个变量的路径zabbix_base +'script/tomcat/monitor_nginxlog_line.safe<br>

* 使用时分python版本：<br>
    * python2：/usr/bin/python2 log_keyword2.py log_path haha,hhh,hhhh<br>
    * python3：/usr/bin/python3 log_keyword3.py log_path haha,hhh,hhhh<br>
    
    `其中log_path 是日志的路径，haha,hhh,hhhh 是关键字，关键字可以是多个关键字，必须用逗号分割。`<br>

##### 2、log_status.sh<br>
* 这个是之前用shell写的脚本，有很多缺陷，现在不变动了，有时间了，用shell写出和[1]相似功能的脚本,需要传入关键字的参数

##### 最后关于这些脚本如何在zabbix中使用：<br>
* 在zabbix_agent的配置文件“zabbix_agent/etc/zabbix_agentd.conf”中添加以下内容<br>
```

UserParameter=log.error[*], /usr/local/zabbix_agentd/sbin/log_status.sh $1###查找日志中是否有关键字报错，$1是关键字，参照[2]，传入的关键是log.error[*]中的*，是在服务端设定的<br>

```