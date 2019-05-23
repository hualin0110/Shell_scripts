#!/bin/bash
##
##传入hostname的前缀
read -p "请输入hostname的前缀: " pre_name
#如果不想手动输入，可以在下面的pre_name直接写要的值
#pre_name=$1
host_version=$(rpm -q centos-release |cut -d - -f3)
echo "$host_version"
if [ "$host_version" = "7" ]
then
        IN_Face=`route -n |awk '{if($4~/U/){print $8}}'|head -n 1`
        ipfull=`ip a|grep -B1 -C1 -w "$IN_Face" | grep -w 'inet' |awk '{print $2}' |awk -F'/' '{print $1}'`
        ipmachine=`echo $ipfull|awk -F. '{print $3"-"$4}'`
        machine=$pre_name-$ipmachine #if want user-defined hostname ,you can use this line and run by one parameter
#       machine=zqsign-$ipmachine
#       sed -i 's/\(^HOSTNAME=\).*/\1'$machine'/g' /etc/sysconfig/network
        if [[ -z `grep "$machine" /etc/hosts` ]]
        then
                echo $ipfull $machine
                echo $ipfull $machine >> /etc/hosts
                hostname $machine
                >/etc/hostname
                echo "$machine" >>/etc/hostname
        else
                sed -i  /"$ipfull"/'c '"$ipfull $machine"'' /etc/hosts
        fi
        sed -i '/#UseDNS yes/a\UseDNS no' /etc/ssh/sshd_config
        sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/ssh_config
        systemctl restart sshd.service
elif [ "$host_version" = "6" ]
then
        IN_Face=`route -n |awk '{if($4~/UG/){print $8}}'|head -n 1`
        ipfull=`ip a|grep -B1 -C1 -w "$IN_Face" | grep -w 'inet' |awk '{print $2}' |awk -F'/' '{print $1}'`
        ipmachine=`echo $ipfull|awk -F. '{print $3"-"$4}'`
        machine=$pre_name-$ipmachine  #if want user-defined hostname ,you can use this line and run by one parameter
        #machine=zqsign-$ipmachine
        sed -i 's/\(^HOSTNAME=\).*/\1'$machine'/g' /etc/sysconfig/network
        if [[ -z `grep "$machine" /etc/hosts` ]]
        then
                echo $ipfull $machine >> /etc/hosts
                hostname $machine
        else
                sed -i  /"$ipfull"/'c '"$ipfull $machine"'' /etc/hosts
        fi
        sed -i '/#UseDNS yes/a\UseDNS no' /etc/ssh/sshd_config
        sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/ssh_config
        /etc/init.d/sshd restart
fi
/bin/rm -rf rename_v0.1.sh