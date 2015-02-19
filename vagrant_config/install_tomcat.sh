#!/bin/bash
# Inspired by http://www.davidghedini.com/pg/entry/install_tomcat_6_on_centos

logs_dir=/vagrant/vagrant_logs
log_file=$logs_dir/install_tomcat.log
if [ -e "$log_file" ]; then
    rm -f $log_file
fi

exec 3>&1 1>>${log_file} 2>&1

echo "Downloading Tomcat" | tee /dev/fd/3
tomcat_name=apache-tomcat-6.0.43
tomcat_archive=$tomcat_name.tar.gz
tomcat_archive_url=http://apache.uib.no/tomcat/tomcat-6/v6.0.43/bin/$tomcat_archive
tomcat_home=/usr/share/$tomcat_name

curl -o /usr/share/$tomcat_archive $tomcat_archive_url

echo "Installing Tomcat" | tee /dev/fd/3
cd /usr/share
tar -xzf $tomcat_archive
rm -f $tomcat_archive

cat <<EOF> /etc/init.d/tomcat
#!/bin/bash
# description: Tomcat Start Stop Restart
# processname: tomcat
# chkconfig: 234 20 80
CATALINA_HOME=$tomcat_home

case \$1 in
start)
/bin/su tomcat \$CATALINA_HOME/bin/startup.sh
;;
stop)
/bin/su tomcat \$CATALINA_HOME/bin/shutdown.sh
;;
restart)
/bin/su tomcat \$CATALINA_HOME/bin/shutdown.sh
/bin/su tomcat \$CATALINA_HOME/bin/startup.sh
;;
esac
exit 0
EOF

chmod 755 /etc/init.d/tomcat
chkconfig --add tomcat
chkconfig --level 234 tomcat on

groupadd tomcat
useradd -s /bin/bash -g tomcat tomcat
chown -Rf tomcat.tomcat $tomcat_home

echo "Starting Tomcat" | tee /dev/fd/3
service tomcat start

echo "Done" | tee /dev/fd/3
