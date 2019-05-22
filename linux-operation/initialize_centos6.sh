#!/usr/bin/env bash
# Time : 2019/4/1
# Author : "郁唯"
#system version :CentOS 6.x
#此脚本需要用bash命令而非sh命令运行。

##设置安装日志的路径，正常日志以及错误日志。
Log_Path="/tmp/soft_install"
LOG="$Log_Path/install.log"
ERRORLOG="$Log_Path/install.error"

##software from remote host
#huaweicloud
#remote_repositories="192.168.0.43"
#taixing
remote_repositories="192.168.1.210"
#ntp服务器server，如果是内网，请在此处填写内网地址。如果直接从外网同步时间，就用下面的ntp.api.bz
ntp_server="ntp.api.bz"



if [[ ! -d $Log_Path ]];then
    mkdir $Log_Path
fi

echo > ${LOG}
echo > ${ERRORLOG}

##获取机器完整的内网ip
IN_Face=`route -n |awk '{if($4~/UG/){print $8}}'|head -n 1`
ipfull=`ip a|grep -B1 -C1 -w "${IN_Face}"|grep -w 'inet'|awk '{print $2}'|awk -F\/ '{print $1}'|head -n 1`

##获取时间
get_time(){
	current_time=$(date +'%Y-%m-%d %H:%M:%S')
	echo -e "$current_time =====>>$1" |tee -a  $LOG

}

close_X11() {
	get_time "Start the funciton close_X11"
	is_X11=`grep "id:5:initdefault" /etc/inittab |wc -l `
	if [ $is_X11 -eq 1 ];then
		echo -e "The runlevel of system is 5, need to change it"
		sed -i 's/id:5:initdefault/id:3:initdefault/g' /etc/inittab
		get_time "The runlevel of system is change from 5 to 3  \nend"
#		echo -e "The runlevel of system is change from 5 to 3  \nend" |tee -a  $LOG
	elif [[ $is_X11 -eq 0 ]]; then
		get_time "The runlevel of system is 3, don't need to change it "
	else
		get_time
		echo -e "\033[1;31mThe changing about runlevel of system is failed,please check it [0m" |tee -a  $ERRORLOG
	fi
}


change_vim(){
	echo -e "Change vim setting "
	echo 'set enc=cp936' > ~/.vimrc
	echo 'set fenc=cp936' >> ~/.vimrc
	echo 'set tabstop=2' >> ~/.vimrc
	echo 'set shiftwidth=2' >> ~/.vimrc
	echo 'set expandtab' >> ~/.vimrc
	echo 'set fencs=cp936,utf-8,ucs-bom,gbk,gb18030,gb2312 ' >> ~/.vimrc
	get_time "The Setting of vim is already changed  \nend"
}
close_iptables(){
	is_down=`chkconfig --list iptables|grep on |wc -l`
	if [[ $is_down -eq 1 ]]; then
		chkconfig iptables off
		get_time "The iptables is already stoped  \nend"
	else
		get_time "The iptables is not started  \nend"
	fi

}

close_selinux(){
	get_time "start to close selinux"
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
	setenforce 0
	value_selinux=`getenforce`
	conf_selinux=`grep "SELINK=disabled" /etc/selinux/config|wc -l `
	if [[ $value_selinux == "Permissive" && $conf_selinux -eq 1  ]]; then
		get_time " selinux has successsfully shutdown!"
	else
		get_time "shutdown Selinux is ERROR"
	fi
}

time_set(){
	get_time "start set timezone and it's crontab"
	mv /etc/sysconfig/clock /etc/sysconfig/clock.bak
	echo 'ZONE="Asia/Shanghai"' >/etc/sysconfig/clock
	echo 'UTC=true' >>/etc/sysconfig/clock
	echo 'ARC=false' >>/etc/sysconfig/clock
	cp /usr/share/zoneinfo/Asia/Shanghai /tmp/tmp
	mv -f /tmp/tmp /etc/localtime
	get_time "The timezone is already setted "
	#这个地方的ntp.api.bz，如果主机是内网且有内网时间服务器，可以修改为内网服务器地址
	if [[ -z `grep 'ntp.api.bz' /var/spool/cron/root` ]]
	then
	    echo 'MAILTO=""' >> /var/spool/cron/root
		echo "*/10 * * * * /usr/sbin/ntpdate -u ntp.api.bz > /dev/null  2>&1" >> /var/spool/cron/root
	fi
	get_time "The crontab of datetime is already setted"
}
ssh_set(){
	get_time "配置ssh的客户端不断开，并且其他主机连接过来的时候，不使用dns检查是否有该主机"
	value_sshalive=$(grep -e "^TCPKeepAlive yes" /etc/ssh/sshd_config |wc  -l)
	value_clientalive=$(grep -e "^ClientAliveInterval" /etc/ssh/sshd_config |wc  -l)
	value_usedns=$(grep 'UseDNS no' /etc/ssh/sshd_config |wc -l)

	if [[ $value_sshalive -eq 0 ]]; then
		echo "TCPKeepAlive yes" >>/etc/ssh/sshd_config | tee -a $LOG
	fi

	if [[ $value_clientalive -eq 0 ]]; then
		echo "ClientAliveInterval 600" >>/etc/ssh/sshd_config  |tee -a $LOG
	elif [[ $value_sshalive -ge 1 ]]; then
		sed -i '/ClientAliveInterval/d' /etc/ssh/sshd_config |tee -a $LOG
		echo "ClientAliveInterval 600" >>/etc/ssh/sshd_config  |tee -a $LOG
	else
		echo "The changing of ClientAliveInterval is Error ,please check it by yourself" |tee -a $ERRORLOG
	fi

	if [[ $value_usedns -eq 0 ]]; then
		echo "UseDNS no" >>/etc/ssh/sshd_config
		echo "Has change UseDNS to no for the system"  |tee -a $LOG
	elif [[ $value_usedns -ge 1 ]]; then
		echo "The item of UseDNS do not need change ,because 'UseDNS no' already exit "  |tee -a $LOG
	else
		echo "The changing of UseDNS is Error ,please check it by yourself" |tee -a $ERRORLOG
	fi
	/etc/init.d/sshd restart
	RETVAL=$?
	if [ $RETVAL -eq 0 ]; then
		echo "The service of sshd has already restart  " |tee -a $LOG
	else
		echo "The service of sshd has go wrong when restarting" |tee -a $ERRORLOG
	fi

	get_time "配置免密登录"
	rsync -aP -e "ssh -o StrictHostKeyChecking=no"  root@$remote_repositories:/soft/ssh/* /root/.ssh/
}

service_setting(){
	get_time "设置开机启动的服务"
	apps='acpid anacron atd auditd autofs avahi-daemon bluetooth cpuspeed cups firstboot gpm haldaemon hidd hplip ip6tables irqbalance  isdn kudzu lvm2-monitor mcstrans mdmonitor messagebus microcode nfslock pcscd portmap readahead_early readahead_later restorecond rpcgssd  rpcidmapd postfix setroubleshoot smartd xinetd iptables nscd '
	for i in $apps; do
		chkconfig $i off
	done
	echo "The useless service  do not start  when the system starting " |tee -a $LOG

	get_time
	echo "The usefull service  will starting when the system starting " |tee -a $LOG
	chkconfig --level 2345 crond on
	chkconfig --level 2345 netfs on
	chkconfig --level 2345 network on
	chkconfig --level 2345 sshd on
	chkconfig --level 2345 syslog on
	chkconfig --level 2345 sysstat on
	chkconfig --level 2345 xfs on
	chkconfig --level 2345 yum-updatesd on
	get_time  "The usefull service  is already setting chkconfig on"

}

system_core(){
	##调整系统内核参数
	get_time "调整系统内核参数"
	echo "" > /etc/sysctl.conf
	cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
# 上面的配置是华为的默认的保留了系统原来的配置，然后添加了下面的东西
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_timestamps = 1
##看了一个文章说，开启timestamps而不开启recycle，是比较好的做法，现在网上给的方案都是开启recycle而不是timestamps，姑且按照华为的来吧。
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_retrans_collapse = 0
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_fin_timeout = 30
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.rp_filter = 1
fs.inotify.max_user_watches = 65536
net.ipv4.conf.default.promote_secondaries = 1
net.ipv4.conf.all.promote_secondaries = 1
net.core.somaxconn = 50000

####add  "deny icmp's redirects"
net.ipv4.conf.all.accept_reditects = 0
EOF
	sysctl -p
	RETVAL=$?
	if [ $RETVAL -eq 0 ]; then
		echo "The options of the system core is already changed " |tee -a $LOG
	else
		echo "The changing of the system core is ERROR ,please chech the options of system core " |tee -a $ERRORLOG
	fi

	get_time "调整打开文件描述符数量"
	if [[ -z `grep 'hard nofile 65536' /etc/security/limits.conf` ]];then
		echo '* soft nofile 65536' >> /etc/security/limits.conf 
		echo '* hard nofile 65536' >> /etc/security/limits.conf
		echo -e "\033[32m file handel has been successfully changed \033[0m"
		ulimit -SHn 65536
		echo "ulimit -SH 65535" >>/etc/rc.local
		echo "1. change ulimit to 65535 success" |tee -a $LOG
	fi

}

modify_yumrepo(){
	get_time "配置yum源"
	is_wget=`rpm -qa |grep wget |wc -l`
	
	yum install -y wget
	cp -a  /etc/yum.repos.d /etc/yum.repos.d.bak
	rm -rf /etc/yum.repos.d/*
#	value_hwmirror=`grep myhuawei CentOS-Base.repo |wc -l`
#	if [[ $value_hwmirror -eq 0 ]]; then
#		wget http://mirrors.myhuaweicloud.com/repo/mirrors_source.sh && sh mirrors_source.sh
#		RETVAL=$?
#		if [ $RETVAL -eq 0 ]; then
#			echo "The changing of yum_repos is already over  " |tee -a $LOG
#		else
#			echo "The changing of yum_repos  is ERROR ,please chech the network of system and so on  " |tee -a $ERRORLOG
#		fi
#	else
#        echo "The repo of yum is already setted" |tee -a $LOG
#	fi
    ##华为云的rpm仓库，线上需要使用这个
    #wget http://mirrors.myhuaweicloud.com/repo/mirrors_source.sh && sh mirrors_source.sh
    ##华为云用上面注释掉的那个部分，泰兴用下面这条命令
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

	yum -y install lrzsz sysstat tree expect vixie-cron syslog xfs yum-updatesd nc dos2unix telnet vim rsync openssh openssh-server openssh-clients

}

safe_rm(){
	safe_rm_dir="/usr/local/safe_rm"
	if [[ ! -d $safe_rm_dir ]]; then
		mkdir $safe_rm_dir
	fi
	##下面的这个’“EOF”‘ 可以将下面字符中的不管需不需转义，都不会转义。
	cat >/usr/local/saferm.sh <<"EOF"
#!/bin/bash
#author: huaxuelin
#date: 2019-04-02
#please do not remove this shell scripts,it is a command scritp for safe rm.

Trash_Dir="/tmp/.trash/"
trash_file=$*

if [[ ! -d $Trash_Dir ]];then
    mkdir $Trash_Dir
fi

case $1 in
	-f )
	echo -e "\033[32m please use the command 'rm' directly,do not use '-f' \033[0m"
		;;
	-rf )
	echo -e "\033[32m please use the command 'rm' directly,do not use '-rf' \033[0m"
		;;
	-h )
	echo -e "\033[32m do not need use any parameters only with this method of 'rm -a filename ...'  \033[0m"
		;;
	-a )
		for i in $trash_file ;do
			if [[ $i == "-a" ]]; then
				continue
			else
				Trash_Date=$(date +'%Y-%m-%d %H:%M:%S')
				Filename=$(basename $i)
				mv $i $Trash_Dir/"$Filename"_"$Trash_Date"
			fi
			done
		;;
	* )
	echo -e "\033[1;32m do not need use any parameters only with this method of 'rm -a filename ...' \033[0m"
		;;
esac
EOF
	echo 'alias rm="sh /usr/local/saferm.sh"' >> /root/.bashrc
	echo "#below set for clean old remove files !!! warning ,do not remove it \n0 0 * * * find  /tmp/.trash/ -mtime +7 |xargs /bin/rm -rf  > /dev/null  2>&1 " >> /var/spool/cron/root

}

fonts_install(){
    #此函数必须在“modify_yumrepo” 函数执行之后才能执行。否则可能会出现不能使用yum安装命令的情况。
    #此函数only use in zqsign.com
    get_time "配置系统字体"
    font_dir="/usr/share/fonts/simsun"
    if [[ ! -d $font_dir ]]; then
        mkdir $font_dir
        echo "mkdir dir $font_dir " |tee -a $LOG
    fi
    echo $remote_repositories
    rsync -aP -e "ssh -o StrictHostKeyChecking=no"  root@$remote_repositories:/soft/fonts/simsun/* $font_dir/
    yum install -y mkfontscale  fontconfig
    mkfontscale && mkfontdir && fc-cache -fv
    fc-list :lang=zh
}

ntp_install(){
    #这个服务如果安装的话，好像就不需要在crontab中添加同步时间的定时任务了
    get_time "安装配置ntp服务"
    rsync -aP -e "ssh -o StrictHostKeyChecking=no"  root@$remote_repositories:/soft/ntp/install_ntp_v2.sh  ./ && sh install_ntp_v2.sh
    RETVAL=$?
    if [ $RETVAL -eq 0 ]; then
        echo "The service of ntpd is already setted " |tee -a $LOG
    else
        echo "It is going wrong when service of ntpd being install,please check it  " |tee -a $ERRORLOG
    fi

}

host_rename(){
    #when use this function,please in this fashion:"hostname zqsign",and the parameter of "zqsign" is what you want to set for the hostmechine
    get_time "修改hostname"
    rsync -aP -e "ssh -o StrictHostKeyChecking=no"  root@$remote_repositories:/soft/scripts/rename_v0.1.sh  ./ && sh rename_v0.1.sh $1
    RETVAL=$?
    if [ $RETVAL -eq 0 ]; then
        echo "The hostname is already resetting ,please reconnect this host mechine " |tee -a $LOG
    else
        echo "It is going wrong when setting hostname ,please check it  " |tee -a $ERRORLOG
    fi
}

jdk_install(){
    get_time "安装配置jdk"
    java_dir="/usr/local/java"
    java_value=$(rpm -qa |grep -e ^java|wc -l)
    value_diyjavapath=$(egrep "JAVA_HOME|JRE_HOME" /etc/profile |wc -l )
    if [[ $java_value -gt 0 ]]; then
        yum remove java*
    else
        echo "there is no java in this system "
    fi

    if [[ ! -d "/usr/java" || ! -d "/usr/local/jdk" ]]; then
        /bin/rm -rf /usr/java && /bin/rm -rf /usr/local/jdk
    fi
    if [[ ! -d $java_dir ]]; then
        mkdir $java_dir
        echo "mkdir dir $java_dir " |tee -a $LOG
    else
        /bin/rm -rf $java_dir/*
    fi

    rsync -aP -e "ssh -o StrictHostKeyChecking=no"  root@$remote_repositories:/soft/java/jdk-8u171-linux-x64.tar.gz $java_dir
    tar xzf $java_dir/jdk-8u171-linux-x64.tar.gz -C $java_dir/
    rsync -aP  $java_dir/jdk1.8.0_171/* $java_dir/
    /bin/rm -rf $java_dir/jdk1.8.0_171 $java_dir/jdk-8u171-linux-x64.tar.gz

    if [[ $value_diyjavapath -ge 1 ]]; then
        for i in "export JAVA_HOME=" "export JRE_HOME=" "export PATH=" "export CLASS_PATH=";do
            sed -i "/$i/d" /etc/profile
            sed -i "/#Set environment variables for Java/d" /etc/profile
        done
    fi

cat >>/etc/profile <<"EOF"
#Set environment variables for Java by 郁唯
export PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export JAVA_HOME=/usr/local/java
export JRE_HOME=/usr/local/java/jre
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
export CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
EOF
    source /etc/profile

    if [[ $(java -version 2>&1|grep "1.8"|wc -l)  -gt 0 ]];then
        get_time "java 1.8  is already be installed in this system"
    fi
}

tomcat_install(){
    get_time "安装tomcat"
    value_tomcat_dir=$(ls /usr/local/ |grep tomcat |wc -l)
    tomcat_dir="/usr/local/tomcat"
    if [ $value_tomcat_dir -ne 0 ]; then
        /bin/rm -rf /usr/local/*tomcat*
    fi
    rsync -aP -e "ssh -o StrictHostKeyChecking=no"  root@$remote_repositories:/soft/tomcat/apache-tomcat-8.0.52.tar.gz /usr/local/src/
    tar xzfP /usr/local/src/apache-tomcat-8.0.52.tar.gz -C /usr/local/src/
    rsync -aP  /usr/local/src/apache-tomcat-8.0.52 /usr/local/tomcat
    get_time  "Install tomcat is already done"
}

nginx_install(){
    echo ""
}

system_init() {
	##此函数将设置调整一些系统的服务参数
	close_X11
	sleep 2
	##可能有一些会用到yum安装的软件，所以在安装所有软件的时候，先用yum安装一些必备的软件。
	modify_yumrepo
	##配置sshd链接并做无秘钥登录
    sleep 2
	ssh_set
	##设置一些关于vim的
	sleep 2
	change_vim
	#一下是关闭iptables和selinux的
	sleep 2
	close_iptables
	sleep 2
	close_selinux
	sleep 2
	##关于时间的set_time
	time_set
	sleep 2
	service_setting
	sleep 2
	system_core
	sleep 2
	safe_rm
	sleep 2
	fonts_install
	sleep 2
	ntp_install
	sleep 2
	##host_rename zqsign 其中的zqsign是需要重命名主机名的前缀
	host_rename zqsign
	sleep 2
    jdk_install
    sleep 2
    tomcat_install
}

if [[ $# -eq 0 ]]; then
    echo -e  "\033[1;32m The funciton of this scripts is [close_X11,change_vim,ssh_set,close_iptables,close_selinux,time_set,modify_yumrepo,service_setting,system_core,safe_rm,fonts_install,ntp_install,host_rename,jdk_install.tomcat_install ] ,this function can be used by option of '-m' and '-s' \033[0m "
    echo "Usage: $0 -a  is install all functions"
    echo "Usage: $0 -s function   install a single function"
    echo "Usage: $0 -m function1 function2 ....   install multiple functions"
    echo "Usage: $0 -h  print the help messages"

elif [[ $# -eq 1 ]]; then
    case $1 in
        -a)
            echo "Will install all funciton , please pay attention"
            system_init
        ;;
        -h)
            echo "Usage: $0 -a  is install all functions"
            echo "Usage: $0 -s function   install a single function"
            echo "Usage: $0 -m function1 function2 ....   install multiple functions"
            echo "Usage: $0 -h  print the help messages"
        ;;
        *)
            echo -e  "\033[1;32m The funciton of this scripts is [close_X11,change_vim,ssh_set,close_iptables,close_selinux,time_set,modify_yumrepo,service_setting,system_core,safe_rm,fonts_install,ntp_install,host_rename,jdk_install.tomcat_install ] ,this function can be used by option of '-m' and '-s' \033[0m "
            echo "Usage: $0 -a  is install all functions"
            echo "Usage: $0 -s function   install a single function"
            echo "Usage: $0 -m function1 function2 ....   install multiple functions"
            echo "Usage: $0 -h  print the help messages"
        ;;
    esac
elif [[ $# -gt 1 ]]; then
    case $1 in
        -s)
            if [[ $2 = "host_rename" ]]; then
#                host_rename zqsign 其中的zqsign是需要重命名主机名的前缀
                $2 zqsign
            else
                echo "Start install $2"
                $2
            fi
        ;;
        -m)
            for i in $*
            do
                if [[ $i = "-m" ]]; then
                    continue
                elif [[ $i = "host_rename" ]];then
#                    host_rename zqsign 其中的zqsign是需要重命名主机名的前缀
                    $2 zqsign
                else
                    echo "$i"
                    $i
                fi
            done
            echo "done"
        ;;
        *)
            echo -e  "\033[1;32m The funciton of this scripts is [close_X11,change_vim,ssh_set,close_iptables,close_selinux,time_set,modify_yumrepo,service_setting,system_core,safe_rm,fonts_install,ntp_install,host_rename,jdk_install.tomcat_install ] ,this function can be used by option of '-m' and '-s' \033[0m "
            echo "Usage: $0 -a  is install all functions"
            echo "Usage: $0 -s function   install a single function"
            echo "Usage: $0 -m function1 function2 ....   install multiple functions"
            echo "Usage: $0 -h  print the help messages"
        ;;

    esac
fi


