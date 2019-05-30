#!/usr/bin/python
# -*- coding: utf-8 -*-
###only used by python27

import requests
import json
import sys
import os

contents={
"告警主机":"192",
"告警    IP":"192",
"告警时间":"111111",
"告警等级": "11"
}

headers = {"Content-Type": "application/json;charset=utf-8"}
api_url = "https://oapi.dingtalk.com/robot/send?access_token=48eb033cf7bc8d400ee26923ef05e96d9bc2781a694447379eb6e0d0d96b9c34"

def msg(text):
    json_text= {
     "msgtype": "text",
        "text": {
            "content": text
        },
        "at": {
            "atMobiles": [
                ""
            ],
            "isAtAll": False
        }
    }
    print requests.post(api_url,json.dumps(json_text),headers=headers).content

if __name__ == '__main__':
    text = sys.argv[1]
    #text = contents
    msg(text)
