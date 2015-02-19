#!/bin/bash

logs_dir=/vagrant/vagrant_logs
if [ ! -e "$logs_dir" ]; then
    mkdir $logs_dir
fi

log_file=$logs_dir/config_httpd.log
if [ -e "$log_file" ]; then
    rm $log_file
fi

exec 3>&1 1>>${log_file} 2>&1

sed -i 's/UseCanonicalName\ Off/UseCanonicalName On/g' /etc/httpd/conf/httpd.conf
sudo sed -i 's/\#ServerName\ www\.example\.com\:80/ServerName localhost\:80/g' /etc/httpd/conf/httpd.conf

ssl_dir=/etc/httpd/ssl
mkdir $ssl_dir

echo "Configuring Apache SSL" | tee /dev/fd/3
openssl req -new -x509 -days 365 -sha256 -newkey rsa:2048 \
-nodes -keyout $ssl_dir/server.key -out $ssl_dir/server.crt \
-subj '/O=KMD/OU=EVA Admin/CN=localhost'

sed -i 's/^SSLCertificateFile.*$/SSLCertificateFile\ \/etc\/httpd\/ssl\/server.crt/g' /etc/httpd/conf.d/ssl.conf
sed -i 's/^SSLCertificateKeyFile.*$/SSLCertificateKeyFile\ \/etc\/httpd\/ssl\/server.key/g' /etc/httpd/conf.d/ssl.conf

echo "Configuring Shibboleth SP" | tee /dev/fd/3
sed -i 's/acl=\".*\"//g' /etc/shibboleth/shibboleth2.xml

service httpd start
service shibd start
