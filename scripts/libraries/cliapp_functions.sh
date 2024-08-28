#!/bin/bash
# Functions to execute cmd on generic host
# ********************************************************************
# Ericsson Radio Systems AB                                     SCRIPT
# ********************************************************************
#
#
# (c) Ericsson Radio Systems AB 2021 - All rights reserved.
#
# The copyright to the computer program(s) herein is the property
# of Ericsson Radio Systems AB, Sweden. The programs may be used
# and/or copied only with the written permission from Ericsson Radio
# Systems AB or in accordance with the terms and conditions stipulated
# in the agreement/contract under which the program(s) have been
# supplied.
#
# ********************************************************************
# Name    : host_functions.sh
# Date    : 26/04/2023
# Revision: A
# Purpose : This library contains functions used to execute commands on workload
#           vm
#
# Version Information:
#       Version Who             Date            Comment
#       0.1     estmann         26/04/2023      Initial draft
#
# Usage   : 
#
# ********************************************************************

#readonly JIRA_USER='S4_Team'


cliapp_ssh_cmd(){

local host=$1 cmd=$2 cmd_out

#cmd_out=$(ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$host "$cmd")
ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$host "$cmd"
#if [ ! -z "$cmd_out" ];then
#  echo "$cmd_out"
#fi
}

cliapp_get_sync_nodes(){


}


host_lock_user(){

local host=$1 user=$2 selector=$3

if [ "$selector" = "lock" ];then
  selector="0"
else
  selector="-1"
fi

if host_ssh_cmd $host "/usr/bin/chage -E$selector $user > /dev/null";then
  return 0
else
  return 1
fi
}

host_get_rpm_info(){

local rpm_name=$1 rpm_info

rpm_info=$(host_ssh_cmd $lms_host "rpm -qa | grep $rpm_name")

echo $rpm_info

}

host_user_exist(){

local host=$1 user=$2

if host_ssh_cmd $host "egrep -w \"^($user)\" /etc/passwd > /dev/null";then
  return 0
else
  return 1
fi
}

host_get_users_by_key(){

local host=$1 key=$2	

users=$(host_ssh_cmd $host "grep $key /etc/passwd | awk -F':' '{print \$1}'")

echo $users
}


host_delete_user(){

local host=$1 user=$2

#echo "DELETING USER $user ON HOST $host"

if host_ssh_cmd $host "pkill -9 -u $user;userdel -r $user >/dev/null";then
  return 0
else
  return 1
fi
}

