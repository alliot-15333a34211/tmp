#!/bin/bash
set -eo pipefail
green='\e[1;32m' 	# green
red='\e[1;31m' 		# red
blue='\e[1;34m' 	# blue  
yellow='\e[1;33m'   # yellow
nc='\e[0m' 		# normal  

# clean the screen
clear 



function ADDUSER(){
  echo -e "[${green} Creating sftp user $USERNAME...  ${nc}]"
  echo -e "[${green} echo "data path: /opt/sftp/$USERNAME" ${nc}]"
  
  useradd -g sftp -s /sbin/nologin $USERNAME ||exit 1
  echo $PASSWORD | passwd --stdin $USERNAME  ||exit 1
  mkdir /opt/sftp/$USERNAME  ||exit 1
  chmod 0755 /opt/sftp/$USERNAME  ||exit 1
  chown root:sftp /opt/sftp/$USERNAME  ||exit 1
  
}

function main(){
  USERNAME=$1
  PASSWORD=$2
  ADDUSER 
}

# judge runing user
if [ $UID -ne 0 ];then 
	echo -e "[${red} Please runing this script by root user ${nc}]"
	exit 1
fi

cat << EOF
================================================================================
This script will help you create sftp user.
				author	:   Alliot    
        date    :   2023-11-09

	     CURRENT USER:   $USER 
	     CURRENT HOST:   $HOSTNAME
================================================================================
EOF


if [ $# -eq 0 ]; then
  read -rt 30 -p "Do you want to continue? (input 'yes' or 'no')" start 
  if [ "${start}" == yes ];then  
    read -rt 30 -p "Input username: " USERNAME
    read -rt 30 -p "Input password: " PASSWORD
    main ${USERNAME} ${PASSWORD}

  elif [ "${start}" == "no" ];then
    echo -e "[${red} Cancel ${nc}"
  else
    echo -e "[${red} Your input was wrong! ${nc}]"
  fi

else
  USERNAME=$1
  PASSWORD=$2
  main ${USERNAME} ${PASSWORD}
fi
