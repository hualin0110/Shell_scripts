#!/usr/bin/python2
# -*- coding: UTF-8 -*-
#########################################################################
# 监控日志，分析关键字，供zabbix报警
# 将脚本放在/usr/local/zabbix/script/linux目录下，给zabbix用户赋予执行权限
# Create Date :  2015-1-9
# Written by : shanks
# Version : 1.0
#python-version:3
#########################################################################
import sys
import os
import subprocess

# 定义zabbix安装目录
zabbix_base = subprocess.getoutput \
    ('ps -ef |grep zabbix_agentd|grep -v "grep"|awk \'{print $NF}\'|uniq|awk -F"sbin" \'{print $1}\'|head -n1');
# print zabbix_base;
# 将日志文件最后一行记录到tmp文件，用于下一次检测关键字时定义开头,文件格式“日志绝对路径 上一次检测的最后一行的行号”
zabbix_monitor_log_tmp = zabbix_base +'script/tomcat/monitor_log_line.safe'

# #以下文件是测试时使用的，因为本机没有这个zabbix
# zabbix_monitor_log_tmp = '/home/hualin/桌面/pipp/monitor_log_line.safe'

def init_log_tmp(log_path):
    # 检测linux目录是否存在，不存在创建
    if os.path.exists(os.path.split(zabbix_monitor_log_tmp)[0]):
        pass
    else:
        subprocess.getoutput('mkdir -p %s ' %(zabbix_monitor_log_tmp[0]) )
    # 检测tmp文件是否存在，不存在创建
    if os.path.exists(zabbix_monitor_log_tmp):
        pass
    else:
        with open(zabbix_monitor_log_tmp, 'w') as c_tmp_file:
            c_tmp_file.write(log_path + ' 0\n')

def check_log(log_path ,error_key):
    # 检测文件是否存在
    if os.path.exists(log_path):
        pass;
    else:
        # print '\nERROR  ' +log_path +' not found!!!'
        print("\nERROR %s not found!!!"%log_path)
        show_help()
    # 从zabbix_monitor_log_tmp中找到log_path上一次读取的最后一行的行号，如果之前没有记录，则认为是从第一行开始
    init_log_tmp(log_path);
    # 获取log_path现在共有多少行
    log_path_line = subprocess.getoutput('wc -l  %s |awk \'{print $1}\''%log_path)
    # 从zabbix_monitor_log_tmp中获取上次检测时的行号
    log_path_line_last = subprocess.getoutput \
        ('awk \'{if ($1=="%s") {print $2}}\' %s'%(log_path,zabbix_monitor_log_tmp))
    # 如果log_path_line_last为空，说明这个日志文件之前没有检测过，现在认为log_path_line_last=0
    if len(log_path_line_last) == 0:
        log_path_line_last =0
        # 由于文件之前没有检测过，因此要添加到zabbix_monitor_log_tmp中
        with open(zabbix_monitor_log_tmp, 'w') as c_tmp_file:
            c_tmp_file.write('%s %s\n'%(log_path,str(log_path_line_last)))

    # 做差值计算结果便是本次检测需要从文件结尾tail的行数，如果差值是负数则检查全部日志
    if int(log_path_line) < int(log_path_line_last):
        # 说明日志文件发生了替换
        cha = log_path_line
    elif int(log_path_line) == int(log_path_line_last):
        # 说明日志文件没有发生任何变化，直接打印0并退出
        key_count = 0
        print(key_count)
        sys.exit(0)
    else:
        cha = int(log_path_line) - int(log_path_line_last);
    # 把关键字字符串做处理，将分隔符由，改为|
    error_key_new = subprocess.getoutput('echo %s|sed \'s/,/|/g\''%(error_key))

    #调试的时候用的
    # print(error_key)
    # print("最新的行数是%s"%log_path_line)
    # print("需要检测最后%s"%cha)
    # print("===%s"%error_key_new)
    # print("检测上次的行数%s"%log_path_line_last)
    #
    # # 获取关键词在时间范围内出现的次数
    key_count = subprocess.getoutput('tail -n %s %s |grep -cE "%s"'%(str(cha),log_path,error_key_new))
    print(key_count)
    # 更新tmp中log_path的行数
    with open(zabbix_monitor_log_tmp, 'w') as c_tmp_file:
        c_tmp_file.write('%s %s\n' % (log_path, str(log_path_line)))

# 帮助
def show_help():
    print('''
    HELP:
        %s [LOG_PATH] [ERROR_KEY]
            LOG_PATH:   absolute path
            ERROR_KEY:  keyword,multi use ',' separate.
        EXP:
            %s /var/log/tomcat.log error_warning
    ''') %(sys.argv[0] ,sys.argv[0])
    sys.exit(1)


if __name__ == '__main__':
    if len(sys.argv) == 3:
        log_path =sys.argv[1]
        error_key =sys.argv[2]
        check_log(log_path ,error_key)
    else:
        show_help()