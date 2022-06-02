#!/bin/bash  

# author: Alliot
# date  : 2022-06-02


green='\e[1;32m' 	# green
red='\e[1;31m' 		# red
blue='\e[1;34m' 	# blue  
yellow='\e[1;33m'   # yellow
nc='\e[0m' 		# normal  

EXCEPTIONS='|jenkins|rzhang|ubuntu|sync|tomcat|developer'

# clean the screen
clear 

function get_users(){
    grep -Ev "nologin|false|root${EXCEPTIONS}" /etc/passwd | awk -F ":" '{print $1}' |xargs
}

function delete_user(){
    echo -e "${red}NOTICE: ${nc}"
    echo -e "[${red}The user the current action is ${blue}[$1]  ${nc}]"

    export del_this="n"
    read -rt 30 -p "Do you want to delete this user ? (input 'y' or 'n')" del_this 
    
    if [ "${del_this}" == "y" ];then  
        userdel "$1" && echo -e "${yellow}[ User ${nc}${blue}[$1]${nc} ${yellow}is deleted. ${nc}]"

    elif [ "${del_this}" == "n" ];then
	    echo -e "${green} [ User ${nc} ${blue}[$1]${nc} ${green}  will be ignore ${nc}]"
    else
        echo -e "[${green} Your input was wrong! ignore user ${blue}[$1] ${nc}]"
    fi

    unset del_this
}




# judge runing user
if [ $UID -ne 0 ];then 
	echo -e "[${red}please runing this script by root user${nc}"
	exit 1
fi

cat << EOF
================================================================================
This script will help you delete users which you don't need anymore.
				author	:   Alliot    
                date    :   2022-06-02

	     CURRENT USER:   $USER 
	     CURRENT HOST:   $HOSTNAME
================================================================================
EOF


read -rt 30 -p "Do you want to continue? (input 'yes' or 'no')" start 
if [ "${start}" == yes ];then  

    for i in $(get_users); do
        delete_user "${i}"
        echo "----------"
    done

elif [ "${start}" == "no" ];then
	echo "cancelled" 
else
    echo "your input was wrong!"
fi
