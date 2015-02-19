#!/bin/bash
# Requires Tomcat 6 installed.
# Implements https://wiki.shibboleth.net/confluence/display/SHIB2/IdPApacheTomcatPrepare

logs_dir=/vagrant/vagrant_logs
log_file=$logs_dir/install_idp.log
if [ -e "$log_file" ]; then
    rm -f $log_file
fi

exec 3>&1 1>>${log_file} 2>&1

tomcat_name=apache-tomcat-6.0.43
tomcat_home=/usr/share/$tomcat_name

dta_ssl_jar=tomcat6-dta-ssl-1.0.0.jar
echo "Downloading $dta_ssl_jar" | tee /dev/fd/3
curl -o $tomcat_home/lib/tomcat6-dta-ssl-1.0.0.jar https://build.shibboleth.net/nexus/content/repositories/releases/edu/internet2/middleware/security/tomcat6/tomcat6-dta-ssl/1.0.0/$dta_ssl_jar

if [ ! -e "$tomcat_home" ]; then
    echo "Cannot find Tomcat installation directory $tomcat_home. Exiting..." | tee /dev/fd/3
    exit 1
fi

echo "Downloading shibboleth IDP" | tee /dev/fd/3
idp_dir_name=shibboleth-identity-provider-3.0.0
idp_archive=$idp_dir_name.tar.gz
cd /opt
wget -q http://shibboleth.net/downloads/identity-provider/latest/$idp_archive
tar xzf $idp_archive
rm -f $idp_archive

idp_home=/opt/$idp_dir_name
cd $idp_home

# Empty lines below are significant, as they represent <enter> keystrokes
. ./install.sh < cat <<EOF




password
password
password
password
EOF

echo "Registering IDP webapp with Tomcat" | tee /dev/fd/3
cat <<EOF> $tomcat_home/conf/Catalina/localhost/idp.xml
<Context docBase="$idp_home/war/idp.war"
         privileged="true"
         antiResourceLocking="false"
         antiJARLocking="false"
         unpackWAR="false"
         swallowOutput="true" />
EOF

service tomcat restart
