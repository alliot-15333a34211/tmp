#!/bin/bash
set -eo pipefail
green='\e[1;32m' 	# green
red='\e[1;31m' 		# red
blue='\e[1;34m' 	# blue  
yellow='\e[1;33m'   # yellow
nc='\e[0m' 		# normal  

# clean the screen
clear 

function DOWNLOAD(){
  echo -e "[${green} Download:  version ${VERSION}...  ${nc}]"
  
  wget https://archive.apache.org/dist/tomcat/tomcat-9/v${VERSION}/bin/apache-tomcat-${VERSION}.tar.gz 
  tar -zxf apache-tomcat-${VERSION}.tar.gz -C ${WORKDIR}
}

function BACKUP(){
   echo -e "[${green} Backup 'lib' and 'bin' to  ${TOMCAT_PATH}/update_backup_$(date +%Y%m%d) ${nc}]"
   mkdir -p ${TOMCAT_PATH}/update_backup_$(date +%Y%m%d)
   cp -a -r ${TOMCAT_PATH}/lib ${TOMCAT_PATH}/update_backup_$(date +%Y%m%d)
   cp -a -r ${TOMCAT_PATH}/bin ${TOMCAT_PATH}/update_backup_$(date +%Y%m%d)
   echo -e "[${green} Backup complete ${nc}]"
}

function REPLACE(){
  echo -e "[${green} Update:  replace .jar...  ${nc}]"
  cp -r ${WORKDIR}/apache-tomcat-${VERSION}/lib/*.jar ${TOMCAT_PATH}/lib/
  cp -r ${WORKDIR}/apache-tomcat-${VERSION}/lib/*.jar ${TOMCAT_PATH}/lib/
  chown -R tomcat:tomcat ${TOMCAT_PATH}/lib/*.jar
  chmod -R 755 ${TOMCAT_PATH}/lib/*.jar

  cp -r ${WORKDIR}/apache-tomcat-${VERSION}/bin/*.jar ${TOMCAT_PATH}/bin/
  cp -r ${WORKDIR}/apache-tomcat-${VERSION}/bin/*.jar ${TOMCAT_PATH}/bin/
  chown -R tomcat:tomcat ${TOMCAT_PATH}/bin/*.jar
  chmod -R 755 ${TOMCAT_PATH}/bin/*.jar
  echo -e "[${green} Replace complete ${nc}]"
}

function RESTART(){
  echo -e "[${green} Update:  service status... ${nc}]"
  # 保存原来的 LESS 环境变量值
  original_less="$LESS"
  # 禁用分页功能
  export LESS="-FX"
  /bin/systemctl status ${SERVICE_NAME}
  # 恢复分页功能
  export LESS="$original_less"
  
  echo -e "[${green} Update:  restart service.. ${nc}]"
  /bin/systemctl restart ${SERVICE_NAME}
  echo -e "[${green} Update:  service status... ${nc}]"
  
  # 保存原来的 LESS 环境变量值
  original_less="$LESS"
  # 禁用分页功能
  export LESS="-FX"
  /bin/systemctl status ${SERVICE_NAME}
  # 恢复分页功能
  export LESS="$original_less"
}


function main(){
  SERVICE_NAME=$1
  TOMCAT_PATH=/usr/local/${SERVICE_NAME}
  WORKDIR=/tmp/

  if [ $2 == "latest" ]; then
    # get LATEST version
    LATEST_VERSION=$(echo $(curl -s https://tomcat.apache.org/download-90.cgi)| grep -oP 'apache-tomcat-\K\d+\.\d+\.\d+' | sort -rV | head -n 1)
    echo -e "[${yellow} Latest Version: ${LATEST_VERSION}  ${nc}]"
    VERSION=${LATEST_VERSION}
  else
    echo -e "[${yellow} The version of tomcat you specific: $2  ${nc}]"
    VERSION=$2
  fi

  echo -e "[${yellow} Current version: ${nc}]"
  /usr/local/${SERVICE_NAME}/bin/version.sh

  DOWNLOAD
  BACKUP 
  REPLACE
  RESTART
  echo -e "[${yellow} Update completed, current version: ${nc}]"
  /usr/local/${SERVICE_NAME}/bin/version.sh
}





# judge runing user
if [ $UID -ne 0 ];then 
	echo -e "[${red} Please runing this script by root user ${nc}]"
	exit 1
fi

cat << EOF
================================================================================
This script will help you update the specific tomcat version.
				author	:   Alliot    
        date    :   2023-07-05

	     CURRENT USER:   $USER 
	     CURRENT HOST:   $HOSTNAME
================================================================================
EOF


if [ $# -eq 0 ]; then
  read -rt 30 -p "Do you want to continue? (input 'yes' or 'no')" start 
  if [ "${start}" == yes ];then  
    read -rt 30 -p "Input tomcat service name: " SERVICE_NAME
    read -rt 30 -p "Input the version you want to update to: " VERSION
    main ${SERVICE_NAME} ${VERSION}

  elif [ "${start}" == "no" ];then
    echo -e "[${red} Cancel ${nc}"
  else
    echo -e "[${red} Your input was wrong! ${nc}]"
  fi

else
  SERVICE_NAME=$1
  VERSION=$2
  main ${SERVICE_NAME} ${VERSION}
fi
