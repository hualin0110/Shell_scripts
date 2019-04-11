#!/bin/bash


downloadpath="/root/huxin/downloadpdf"
mv $downloadpath $downloadpath$(date +%Y-%m-%d)
mkdir -pv $downloadpath

filelists="
group1/M01/5A/37/wKgBEFxvc-SAASuQAADoe9Ugvz4442.pdf
"

for i in $filelists;

do
#echo $i
#filepath=`awk -F "\/" '{ print $2\/$3\/$4}'`
#groupname=`echo $i |awk -F "M00" '{ print $1 }'`
groupname=`echo $i |awk -F "M01" '{ print $1 }'`
#filepath=`echo $i |awk -F "M00" '{ print $2 }'`
filepath=`echo $i |awk -F "M01" '{ print $2 }'`

#echo ${groupname%*/}
#echo $filepath
case "$groupname" in
        group1/)
		rsync -aP  -e "ssh -o StrictHostKeyChecking=no" root@192.168.0.25:/home1/fastdfs/storage/data$filepath  $downloadpath/
                echo "Successfully download the file in group1 "
                ;;
        group2/)
		rsync -aP  -e "ssh -o StrictHostKeyChecking=no"  root@192.168.1.14:/home1/fastdfs/storage/data$filepath  $downloadpath/
                echo "Successfully download the file in group2 "
                ;;
        group3/)
		rsync -aP  -e "ssh -o StrictHostKeyChecking=no"  root@192.168.0.231:/home1/fastdfs/storage/data$filepath  $downloadpath/
                echo "Successfully download the file in group3 "
                ;;
        group4/)
		rsync -aP  -e "ssh -o StrictHostKeyChecking=no"  root@192.168.1.95:/home1/fastdfs/storage/data$filepath  $downloadpath/
                echo "Successfully download the file in group4 "
                ;;
        group5/)
		rsync -aP  -e "ssh -o StrictHostKeyChecking=no"  root@192.168.0.60:/home/fastdfs/storage/data$filepath  $downloadpath/
                echo "Successfully download the file in group4 "
                ;;
esac

done
if [ -f "/root/huxin/downloadpdf.zip" ];then
echo "file is exit,will rm it"
rm -rf /root/huxin/downloadpdf.zip
fi

#tar czfP /root/huxin/downloadpdf.tgz $downloadpath
#echo "use zip command"
#zip -r /root/huxin/downloadpdf.zip $downloadpath

#echo -e "您好：\n附件中是合同文件，请查收。" |mail -s "华雪林发来了合同文件" -a /root/huxin/downloadpdf.zip huxin@51signing.com
#echo -e "您好：\n附件中是合同文件，请查收。" |mail -s "华雪林发来了合同文件" -a /root/huxin/downloadpdf.zip wangqi@51signing.com
#echo -e "您好：\n附件中是合同文件，请查收。" |mail -s "华雪林发来了合同文件" -a /root/huxin/downloadpdf.zip huaxl@51signing.com
