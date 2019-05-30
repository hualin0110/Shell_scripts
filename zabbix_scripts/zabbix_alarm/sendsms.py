!#/usr/local/env python
#coding:utf-8

import sys
import urllib
import urllib2

"""
使用八优短信平台进行短信报警
接收参数输入
参数一:接收手机号(zabbix传来的第1个参数，报警接收手机号)
参数二:短信主题(zabbix传来的第2个参数，报警主题)
参数三:短信内容(zabbix传来的第3个参数，报警内容)


手动调试方法

python sendsms.py *********** "报警测试"

"""
def sendsms(phone,subject,message):
    """
    发送短信
    """
    cdkey = '***********'
    password = '******'
    
    values = {'cdkey':cdkey,
              'password':password,
              'phone':phone,
              'message':message}
    
    data = urllib.urlencode(values)
    post_url = 'http://sdk4report.eucp.b2m.cn:8080/sdkproxy/sendsms.action'
    try:
        conn = urllib2.urlopen(post_url,data)
        print conn.read()
    except Exception , e:
        print e
        
if __name__ == '__main__':
    
    phone = sys.argv[1]
    subject = sys.argv[2]
    message = sys.argv[3]
    
    sendsms(phone,subject,message)
