#!/bin/bash

logs_dir=/vagrant/vagrant_logs
if [ ! -e "$logs_dir" ]; then
    mkdir $logs_dir
fi

log_file=$logs_dir/install_packages.log
if [ -e "$log_file" ]; then
    rm $log_file
fi

exec 3>&1 1>>${log_file} 2>&1

echo "Installing dependencies..." | tee /dev/fd/3

#su vagrant -c "mkdir /home/vagrant/bin"
#su vagrant -c "mkdir /home/vagrant/logs"

echo "export TZ='Europe/Oslo'" > /etc/profile.d/timezone.sh

echo "Disabling SELinux" | tee /dev/fd/3
setenforce permissive
sed -i 's/SELINUX=\(enforcing\|disabled\)/SELINUX=permissive/g' /etc/selinux/config

echo "Installing packages..." | tee /dev/fd/3
yum install -y unzip curl 2>&1

echo "Downloading shibboleth.repo" | tee /dev/fd/3
curl http://download.opensuse.org/repositories/security://shibboleth/CentOS_CentOS-6/security:shibboleth.repo -o /etc/yum.repos.d/shibboleth.repo

echo "Installing Apache httpd and Shibboleth..." | tee /dev/fd/3
yum install -y httpd mod_ssl shibboleth.x86_64 2>&1

echo "done" | tee /dev/fd/3
