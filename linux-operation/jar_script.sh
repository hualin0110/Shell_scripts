#!/usr/bin/env bash
##

#set java environment variable
export JAVA_HOME=/usr/local/java/
export JRE_HOME=/usr/local/java/jre
#设置java启动程序的参数比如初始化内存和堆内存相关
JAVA_OPTS="-Xms768m -Xmx768m -XX:+UseConcMarkSweepGC -Duser.timezone=GMT+08  -XX:+PrintGCDateStamps  -XX:+PrintGCDetails -Xloggc:gc.log -XX:+DisableExplicitGC"

#获取当前脚本运行的目录
BASEPATH=$(
    cd $(dirname $0)
    pwd
)
#获取当前项目的jar包名称
JARFILE=$(ls *jar)
#获取当前项目的项目名
PROG=$(echo $JARFILE | awk -F '.jar' '{ print $1 }')
#自定义PIDFILE路径
PIDFILE=$BASEPATH/$PROG.pid

status() {
    if [ -f $PIDFILE ]; then
        PID=$(cat $PIDFILE)
        if [ ! -x /proc/${PID} ]; then
            return 1
        else
            return 0
        fi
    else
        return 1
    fi
}

#这是第二种解决找到pid的情况，感觉和第一种相比没有太大的差别。只是写法不一样而已。
# 设置一个全局环境变量psid
psid=0
checkpid() {
    javaps=$(ps -ef | grep -v grep | grep $JARFILE)

    if [ -n "$javaps" ]; then
        psid=$(echo $javaps | awk '{print $2}')
    else
        psid=0
    fi
}

case "$1" in
start)
    checkpid
    status
    RETVAL=$?
    if [ $RETVAL -eq 0 ]; then
        echo "$PIDFILE  exists, process is already running or crashed"
        exit 1
        #        elif [ $RETVAL -ne 0 ];then
    else
        echo "Starting $PROG ..."
        ##-u 添加文件到jar中的指定目录，-v显示过程；-f指定jar包；
        #            jar  -uvf $JARFILE BOOT-INF/classes/*.properties BOOT-INF/classes/*.xml
        #            nohup $JAVA_OPTS java -jar $BASEPATH/$JARFILE >/dev/null 2>&1 &
        nohup java -jar $BASEPATH/$JARFILE >/dev/null 2>&1 &
        ##$?获取shell中命令的结束代码
        RETVAL=$?
        if [ $RETVAL -eq 0 ]; then
            echo "$PROG is already started"
            ##$！获取shell中最后运行的后台process的PID
            echo $!
            echo $! >$PIDFILE
            exit 0
        else
            echo " $PROG start anomaly,please check the starting of $PROG"
            rm -f $PIDFILE
            exit 1
        fi
    fi
    ;;
stop)
    status
    RETVAL=$?
    if [ $RETVAL -eq 0 ]; then
        echo "Shuting down $PROG"
        PID=$(cat $PIDFILE)
        kill -9 $PID
        RETVAL=$?
        if [ $RETVAL -eq 0 ]; then
            rm -f $PIDFILE
        else
            echo "Failed to stopping $PROG"
        fi
    else
        echo "$PROG is already stoped , don't retry it please"
    fi
    ;;
status)
    status
    RETVAL=$?
    if [ $RETVAL -eq 0 ]; then
        PID=$(cat $PIDFILE)
        echo "$PROG is running ($PID)"
    else
        echo "$PROG is not running"
    fi
    ;;
restart)
    $0 stop
    $0 start
    ;;
*)
    echo "Usage : $0 {start | stop | restart | status}"
    ;;
esac
