#!/usr/bin/env bash

cd /tmp
wget --quiet http://maven-repo.evolvis.org/releases/org/osiam/osiam-distribution/1.3.2/osiam-distribution-1.3.2.tar.gz
tar -xzf osiam-distribution-1.3.2.tar.gz

cd osiam-distribution-1.3.2

mkdir /etc/osiam
cp -r osiam-server/osiam-resource-server/configuration/* /etc/osiam
cp -r osiam-server/osiam-auth-server/configuration/* /etc/osiam
cp -r addon-self-administration/configuration/* /etc/osiam
cp -r addon-administration/configuration/* /etc/osiam

psql -h 127.0.0.1 -f osiam-server/osiam-auth-server/sql/drop_all.sql -U ong
psql -h 127.0.0.1 -f osiam-server/osiam-auth-server/sql/init_ddl.sql -U ong
psql -h 127.0.0.1 -f osiam-server/osiam-resource-server/sql/drop_all.sql -U ong
psql -h 127.0.0.1 -f osiam-server/osiam-resource-server/sql/init_ddl.sql -U ong
psql -h 127.0.0.1 -f osiam-server/osiam-resource-server/sql/init_data.sql -U ong
psql -h 127.0.0.1 -f addon-self-administration/sql/init_data.sql -U ong
psql -h 127.0.0.1 -f /tmp/setup_data.sql -U ong

sed -i "/^shared\.loader=/c\shared.loader=/var/lib/tomcat7/shared/classes,/var/lib/tomcat7/shared/*.jar,/etc/osiam" /etc/tomcat7/catalina.properties
sed -i "/^JAVA_OPTS=/c\JAVA_OPTS=\"-Djava.awt.headless=true -Xms512m -Xmx1024m -XX:+UseConcMarkSweepGC\"" /etc/default/tomcat7
service tomcat7 restart

find . -name '*.war' -exec cp {} /var/lib/tomcat7/webapps/ \;
