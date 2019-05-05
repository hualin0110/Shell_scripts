#!/usr/bin/python2.7
# -*- coding: UTF-8 -*-
#author : huaxuelin
#python-version :2.7
##清理fastdfs的文件，按照时间判定
from __future__ import division
import sys,os
import commands
import datetime,time

Disk_detail_tmp = "/home/disk_detail_tmp"
Last_time_tmp = "/home/last_time_tmp"

def get_disk_used_percent():
#    with open(Disk_detail_tmp,"w")  as f:
#        f.write(commands.getoutput("/usr/bin/fdfs_monitor /etc/fdfs/storage.conf"))
    total_space = int(commands.getoutput('grep "disk total space" %s |awk \'{sum += $5} END {print sum}\'' % Disk_detail_tmp))
    free_space = int(commands.getoutput('grep "disk free space" %s |awk \'{sum += $5} END {print sum}\'' % Disk_detail_tmp))
    disk_percent = '%.0f' %((total_space - free_space)/total_space*100)
    return int(disk_percent) ##返回int格式的磁盘剩余空间

def write_time():
    with open(Last_time_tmp,"w")  as fi:
        fi.write('%.0f' %time.time())

def check_time():
    nowTime = time.time()
    lastTime = int(commands.getoutput('cat %s' %Last_time_tmp))
    ##以小时作为时间单位。
    time_Interval_hour = '%.0f' %((int(nowTime) - lastTime)/3600)
    return int(time_Interval_hour) ##返回int 格式的时间,当前时间和上次时间的差值小时数

def check_disk_percent(disk_used_percent):
    if disk_used_percent <= 60:
        pass
    elif disk_used_percent <= 70:
        print("The space of the disk is nearly full")
    else:
        print("the diskspace is bigger than 70")
        clean_fdfs_data(check_time())

def clean_fdfs_data(interval_time):
    if interval_time >= 720:
        print("clean disk file before 30 days ago" )
#        write_time()
    elif interval_time >= 168:
        print("clean disk file before 7 days ago" )
#        write_time()
    elif interval_time >= 72:
        print("clean disk file before 3 days ago" )
#        write_time()
    else:
        print("warning ,The data is too big in last three days")



if __name__ == '__main__':
    check_disk_percent(get_disk_used_percent())
