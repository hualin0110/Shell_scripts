#!/bin/bash
##for shadowsocks and privoxy restart
##for set http_proxy and https_proxy


set_env_proxy()
{
    unset $http_proxy
    unset $https_proxy
    source /etc/profile
}
check_env_proxy()
{

    if [ ! -z `/usr/bin/env |grep http*_proxy` ]
    then
        http_env_proxy=8118
        https_env_proxy=8118

    else
        http_env_proxy=0
        https_env_proxy=0

    fi
}

check_sslocal()
{
    sslocalps=`ps -ef |grep sslocal|grep -v grep`
    if [ -n "$sslocalps" ]
    then
        sslocalpid=`echo $sslocalps|awk '{ print $2 }'`
    else
        sslocalpid=0
    fi
}
check_privoxy()
{
    privoxyps=`ps -ef |grep privoxy|grep -v grep`
    if [ -n "$privoxyps" ]
    then
        privoxypid=`echo $privoxyps|awk '{ print $2 }'`
    else
        privoxypid=0
    fi
}


dostart()
{
    check_env_proxy
    check_privoxy
    check_sslocal
    if [ $sslocalpid -ne 0  ]
    then
        echo "sslocal has already start "
#        kill -9 $sslocalpid
#        nohup sslocal ‐c /etc/shadowsocks/shadowsocks.json > /tmp/shadowsocks.log 2>&1 &
    else
        echo "sslocal is starting"
        ##下面的这个地方，可能有点儿问题。启动的时候会报错。这个地方需要注意下。需要手动启动。
        nohup /usr/bin/python /usr/local/bin/sslocal -c /etc/shadowsocks/shadowsocks.json >> /tmp/shadowsocks.log 2>&1 &
        echo "sslocal is started"
    fi

    if [ $privoxypid -ne 0  ]
    then
        echo "privoxy has already start "
#        kill -9 $privoxypid
#        systemctl start privoxy
    else
        echo "privoxy is starting"
        systemctl start privoxy
        echo "privoxy is started"
    fi


    if [ $http_env_proxy -ne 0  ]
    then
        echo "http_proxy has already seted "
    else
        echo "http_proxy is setting"
        set_env_proxy
        echo "http_proxy is setted"

    fi


}
dostop()
{
    check_env_proxy
    check_privoxy
    check_sslocal
    if [ $sslocalpid -ne 0  ]
    then
        kill -9 $sslocalpid
    fi

    if [ $privoxypid -ne 0  ]
    then
        kill -9 $privoxypid
        systemctl stop privoxy
    fi


    if [ $http_env_proxy -ne 0  ]
    then
        unset http_proxy
        unset https_proxy
    fi
    echo "all is already stoped"
}
dorestart()
{
    dostop
    dostart
}
dostatus()
{
    check_env_proxy
    check_privoxy
    check_sslocal
    if [ $sslocalpid -ne 0  ]
    then
        echo "sslocal is already starting"
    else
        echo "sslocal is stoped"
    fi

    if [ $privoxypid -ne 0  ]
    then
        echo "privoxy is already starting"
    else
        echo "privoxy is stoped"
    fi


    if [ $http_env_proxy -ne 0  ]
    then
        echo "http_proxy is already set"
    else
        echo "http_proxy is not set"
    fi
}

case $1 in
    start)
        dostart
        ;;

    stop)
        dostop
        ;;
    restart)
        dorestart
        ;;
    status)
        dostatus
        ;;
    *)
        echo $"Usage: $0 {start|stop|restart|status}"
        RETVAL=2

esac
