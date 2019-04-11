#!/usr/bin/env bash
# Time : 2019/4/3
# Author : "郁唯"
#!/bin/bash

echo "hello world"

echo 'root:@BJZQKJ2019@zqsign!' |chpasswd

echo "success reset password" |tee -a modify_passwd.log
