#!/bin/bash  
# 日志文件目录  
#path=/usr/local/tomcat/logs
# 找到最新的日志文件名 ls -t 按照时间排序，最新的在上面  
#esb_file=`ls -t "${path}" | head -1`
metric=$1
tmp_file=/tmp/tomcat.log.txt
pathdir=/usr/local/zqsign*service*/logs/catalina.out
case $metric in  
   FastDFSException)  
          output=$(tail -n 500 $pathdir|grep FastDFSException|wc -l)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi  
        ;; 
    NullPointer)
		  output=$(tail -n 200 $pathdir|grep NullPointer|wc -l)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi  
        ;;
    OutOfMemoryError)
		  output=$(tail -n 200 $pathdir|grep OutOfMemoryError|wc -l)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi  
        ;;
         *)
		  output=$(tail -n 200 $pathdir|grep $metric|wc -l)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi  
        ;;
          #echo -e "\e[033mUsage: sh  $0 [FastDFSException|NullPointer|OutOfMemoryError]\e[0m"

esac
