#!/bin/bash
## Install Vsftp
#systemctl version :centos7
#author:郁唯
#

#stop firewall
systemctl stop firewalld
systemctl disable firewalld

if [[ -z `grep -E 'SELINUX=(enforcing|permissive)' /etc/sysconfig/selinux` ]]
then
	sed -i 's/SELINUX=\(enforcing\|permissive\)/SELINUX=disabled/g' /etc/sysconfig/selinux
fi

###set epel.repo
if [[ ! -f /etc/yum.repos.d/epel.repo ]]
then
	yum install -y epel-release
else
	echo 文件已存在
fi

### Install vsftpd ###
yum install -y vsftpd
#install the dependence of vsftpd
yum install -y psmisc net-tools systemd-devel libdb-devel perl-DBI ftp
systemctl start vsftpd.service
systemctl enable vsftpd.service

###set the configure of the vsftpd
cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf-bak

sed -i "s/anonymous_enable=YES/anonymous_enable=NO/g" '/etc/vsftpd/vsftpd.conf'

sed -i "s/#anon_upload_enable=YES/anon_upload_enable=NO/g" '/etc/vsftpd/vsftpd.conf'

sed -i "s/#anon_mkdir_write_enable=YES/anon_mkdir_write_enable=YES/g" '/etc/vsftpd/vsftpd.conf'

sed -i "s/#chown_uploads=YES/chown_uploads=NO/g" '/etc/vsftpd/vsftpd.conf'

sed -i "s/#async_abor_enable=YES/async_abor_enable=YES/g" '/etc/vsftpd/vsftpd.conf'

sed -i "s/#ascii_upload_enable=YES/ascii_upload_enable=YES/g" '/etc/vsftpd/vsftpd.conf'

sed -i "s/#ascii_download_enable=YES/ascii_download_enable=YES/g" '/etc/vsftpd/vsftpd.conf'

sed -i "s/#ftpd_banner=Welcome to blah FTP service./ftpd_banner=Welcome to FTP service./g" '/etc/vsftpd/vsftpd.conf'
##注意下方命令中的guest_username=vsftpd，此命令是指定虚拟用户的宿主用户
echo -e "use_localtime=YES\nlisten_port=21\nchroot_local_user=YES\nidle_session_timeout=300\ndata_connection_timeout=1\nguest_enable=YES\nguest_username=vsftpd\nuser_config_dir=/etc/vsftpd/vconf\nvirtual_use_local_privs=YES\npasv_min_port=10060\npasv_max_port=10090\naccept_timeout=5\nconnect_timeout=1" >> /etc/vsftpd/vsftpd.conf

##create virtul userlist
> /etc/vsftpd/virtusers
cat >> /etc/vsftpd/virtusers <<EOF
ftpd
zhxy2015col
EOF

echo "====successfully create virtul userlist "
###create the db_file for virtul user 
if [[ ! -f /usr/bin/db_load ]]
then
	yum -y install db4
fi

/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtusers /etc/vsftpd/virtusers.db

chmod 600 /etc/vsftpd/virtusers.db

#配置db_file文件生效
cp /etc/pam.d/vsftpd /etc/pam.d/vsftpdbak
sed -i '1 i\auth sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/virtusers' /etc/pam.d/vsftpd
sed -i '1 i\account sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/virtusers' /etc/pam.d/vsftpd


echo "====successfully 配置db_file "
#create system user
useradd vsftpd -d /home/vsftpd -s /sbin/nologin
chown vsftpd:vsftpd /home/vsftpd -R
###create virtual user’s  configure
##create virtual dir
mkdir -p /etc/vsftpd/vconf
#create virtual user datadir
mkdir -p /home/vsftpd/ftpd/



touch /etc/vsftpd/vconf/ftpd
cat >>/etc/vsftpd/vconf/ftpd <<EOF
local_root=/home/vsftpd/ftpd/
write_enable=YES
anon_world_readable_only=NO
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
EOF

echo "====successfully create virtual user’s  configure"
##启动vsftpd 服务。
systemctl restart vsftpd