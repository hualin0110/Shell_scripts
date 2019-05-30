#!/bin/bash
file=/tmp/zabbix_mail.txt
echo "$3" > $file
dos2unix -k $file
/bin/mail -s "$2" $1 < $file
