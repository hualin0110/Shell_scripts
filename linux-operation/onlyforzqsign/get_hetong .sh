#!/bin/bash

require_filelists="
group1/M00/2E/52/wKgBz1zmUdCAYf6oAC93m3Laxk8428.zip
"

workpath="/root/huxin"
downloadpath="$workpath/downloadpdf"
if [[ -d $downloadpath ]]; then
	mv $downloadpath $workpath/downloadpath$(date +%Y-%m-%d)
	mkdir -pv $downloadpath
else
	mkdir -pv $downloadpath
fi

for i in $require_filelists;do
	filename=$(echo $i|awk -F "/" '{ print $5 }')
	/usr/bin/fdfs_download_file /etc/fdfs/client.conf $i $downloadpath/$filename

done

if [ -f "/root/huxin/downloadpdf.zip" ];then
	echo "file is exit,and we will delete it"
	rm -rf /root/huxin/downloadpdf.zip
fi

echo "will tar the downloadpath starting"
tar czfP /root/huxin/downloadpdf.tgz $downloadpath
echo "tar the download path is already successfully end"
# zip -r /root/huxin/downloadpdf.zip $downloadpath

#echo -e "您好：\n附件中是合同文件，请查收。" |mail -s "华雪林发来了合同文件" -a /root/huxin/downloadpdf.zip huxin@51signing.com
#echo -e "您好：\n附件中是合同文件，请查收。" |mail -s "华雪林发来了合同文件" -a /root/huxin/downloadpdf.zip wangqi@51signing.com
#echo -e "您好：\n附件中是合同文件，请查收。" |mail -s "华雪林发来了合同文件" -a /root/huxin/downloadpdf.zip huaxl@51signing.com
