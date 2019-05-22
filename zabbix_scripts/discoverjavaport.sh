
#!/bin/bash
##exclude_port这些进程是不需要的，如果需要屏蔽检测某些进程的端口，只需要在下面|grep CloudResetPwdUpdateAgent的后面，在添加|grep -v xxxx 即可。
exclude_port=$(ps -ef |grep java |grep CloudResetPwdUpdateAgent |awk '{ print $2 }'|xargs |sed 's/ /\|/g')
##将需要的java端口检索出来。添加egrep -v 是为了屏蔽某些不需要的进程，所有的端口号，都会在下面的这个变量里面，但是将所有的端口取出来需要使用:${portarray[@]}
portarray=(`sudo /bin/netstat -tnlp|egrep -i java|egrep -v $exclude_port|awk {'print $4'}|awk -F':' '{if ($NF~/^[0-9]*$/) print $NF}'|sort|uniq`)
#portarray=(`sudo /bin/netstat -tnlp|egrep -i java|awk {'print $4'}|awk -F':' '{if ($NF~/^[0-9]*$/) print $NF}'|sort|uniq`)
length=${#portarray[@]}
printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$length;i++))
  do
     printf '\n\t\t{'
     printf "\"{#JAVA_PORT}\":\"${portarray[$i]}\"}"
     if [ $i -lt $[$length-1] ];then
                printf ','
     fi
  done
printf  "\n\t]\n"
printf "}\n"