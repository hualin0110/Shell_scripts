如何使用监控日志的脚本
---------------
这些文件夹中都是zabbix监控日志的脚本。

##### 1、tcp_conn_status.sh<br>
* 这个脚本是检测tcp各种状态（如：establish，timeout等）的脚本，会将各个状态的数量反馈给zabbix

##### 2、check_zookeeper.sh<br>
* 检测zookeeper状态的脚本，专门给zookeeper使用

##### 3、discoverjavaport.sh<br>
* 这个脚本是用来自动发现java端口的，脚本内容之支持监控java，不过改改的话，可以支持nginx等。but，我觉得一个主机中运行多个tomcat比较现实，运行多个nginx好像没有这种情况

##### 最后关于这些脚本如何在zabbix中使用：<br>
* 在zabbix_agent的配置文件“zabbix_agent/etc/zabbix_agentd.conf”中添加以下内容<br>
```
UserParameter=tomcat_zookeeper,ps -ef|grep -v grep|grep  zookeeper |wc -l###检测zookeeper是否存活<br>
UserParameter=tcp.status[*],/usr/local/zabbix_agentd/sbin/tcp_conn_status.sh $1###检测tcp状态，其中$1是zabbix服务端设定的（tcp.status[*]关键字是*）要检测的字段（如establish、timeout等）<br>
UserParameter=javaport,/usr/local/zabbix_agentd/sbin/discoverjavaport.sh<br>
UserParameter=zookeeper[*],/bin/bash /usr/local/zabbix_agentd/sbin/check_zookeeper.sh $1###使用方法同上<br>
```