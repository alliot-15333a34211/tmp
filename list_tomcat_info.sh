#!/bin/bash

DIR_NAME=`ls /usr/local/ |grep tomcat|xargs`
echo "["
for i in $DIR_NAME;do
  dir_name=$i
  if [ -e /usr/local/$i/webapps ];then
    services=`ls /usr/local/$i/webapps/ | grep war | awk -F '.' '{print$1}'|xargs`
    shutdown_port=`grep port /usr/local/$i/conf/server.xml|grep shutdown |awk -F 'port=' '{print$2}'|awk -F '"' '{print$2}'|xargs`
    service_port=`grep port /usr/local/$i/conf/server.xml | grep -v redirectPort |grep Connector |awk -F 'port=' '{print$2}'|awk -F '"' '{print$2}'|xargs`
    jvm_config=`grep Xm /usr/local/$i/bin/setenv.sh |grep -v '#'|awk -F '-' '{print$2}'|awk -F '"' '{print$1}' |xargs`
  else
    services=null
    shutdown_port=null
    jvm_config=null
  fi
  echo "{\"dir_name\": \"$dir_name\", \"services\": \"$services\", \"shutdown_port\": \"$shutdown_port\", \"service_port\": \"$service_port\", \"jvm_config\": \"$jvm_config\"}, "
done
echo "]"
