#!/bin/bash

logs_dir=/vagrant/vagrant_logs
log_file=$logs_dir/install_java.log
if [ -e "$log_file" ]; then
    rm $log_file
fi

exec 3>&1 1>>${log_file} 2>&1

config_dir=/vagrant/vagrant-config/development
jdk_rpm=jdk-7u75-linux-x64.rpm
jdk_rpm_url=http://download.oracle.com/otn-pub/java/jdk/7u75-b13/$jdk_rpm

policy_zip=UnlimitedJCEPolicyJDK7.zip
policy_zip_url=http://download.oracle.com/otn-pub/java/jce/7/$policy_zip

echo Installing $jdk_rpm... | tee /dev/fd/3

cd /tmp

echo "  * jdk" | tee /dev/fd/3
wget -q --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O $jdk_rpm $jdk_rpm_url
rpm -ivh $jdk_rpm
rm $jdk_rpm

echo "  * unlimited JCE policy" | tee /dev/fd/3
wget -q --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O $policy_zip $policy_zip_url
unzip $policy_zip
cd /usr/java/default/jre/lib/security
mv US_export_policy.jar US_export_policy.jar.orig
mv local_policy.jar local_policy.jar.orig
cp /tmp/UnlimitedJCEPolicy/US_export_policy.jar .
cp /tmp/UnlimitedJCEPolicy/local_policy.jar .
cd /tmp
rm -rf UnlimitedJCEPolicy
rm $policy_zip

echo "  * setup environment" | tee /dev/fd/3
cat <<EOF> /etc/profile.d/java_profile.sh
export JAVA_HOME=/usr/java/default
EOF

. /etc/profile.d/java_profile.sh

echo done | tee /dev/fd/3
