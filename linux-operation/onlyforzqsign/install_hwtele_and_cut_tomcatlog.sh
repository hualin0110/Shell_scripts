#!/usr/bin/env bash
# Time : 2019/4/3
# Author : "郁唯"

cd /usr/local/src/
wget http://telescope.obs.myhwclouds.com/agent/telescope_linux_amd64.tar.gz
tar xzf telescope_linux_amd64.tar.gz
cd telescope_linux_amd64
chmod 755 install.sh && ./install.sh

echo "######install telescope service successfully"

###设置切割日志
echo "##############set cut tomcat logs "


mkdir -pv /root/huaxuelin/
rsync -aP -e "ssh -o StrictHostKeyChecking=no" root@192.168.0.43:/soft/scripts/cut_tomcat_log.sh /root/huaxuelin/
for i in `ls -d /usr/local/zqsign*`;
do
        echo "01 0 * * * /bin/bash /root/huaxuelin/cut_tomcat_log.sh $i/logs  >>/root/huaxuelin/cut_tomcat.log  2>&1 & " >>/var/spool/cron/root
done



echo "check crontab service "
crontab -l