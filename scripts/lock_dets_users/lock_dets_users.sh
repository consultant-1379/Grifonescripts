#!/bin/bash
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
           # Name    : lms_functions.lib
# Date    : 26/04/2023
# Revision: A
# Purpose : This script is locking/unlocking DETS users of LMS/Workload VM
#
#
# Version Information:
#       Version Who             Date            Comment
#       0.1     estmann         26/04/2023      Initial draft
#
# Usage   :
#
# ********************************************************************

. ../libraries/host_functions.sh
. ../libraries/jira_functions.sh
. ../libraries/dmt_dit_functions.sh
. ../libraries/generic_functions.sh

deployment_id=$1
deployment_type=$2
lock_unlock_users=$3
action=$4
users="$5"
discard_users="$6"
issue_status="$7"
remove_unused_dets_users=$8

if [ ${lock_unlock_users} = "false" ] && [ ${remove_unused_dets_users} = "false" ];then
  echo "NO OPTIONS HAVE BEEN SELECTED !"
  echo "PLEASE SELECT lock_unlock_users AND/OR remove_unused_users"
  exit
fi

u_action=$(echo "${action^^}")

banner "${action} DETS USERS ON LMS/WORKLOAD VM"

echo ""

echo "*****SUMMARY OF OPTIONS*****"

echo "DEPLOYMENT_ID:" $deployment_id
echo "DEPLOYMENT TYPE:" $deployment_type
echo "EXECUTE $u_action USERS:" $lock_unlock_users
echo "ACTION:" $action
echo "DETS USERS TO $u_action:" $users
echo "DETS USERS TO DISCARD FROM $u_action:" $discard_users
echo "TICKET_STATUS:" $issue_status
echo "REMOVE UNUSED DETS USERS:" $remove_unused_dets_users

if [ "$users" = "none" ] && [ "$lock_unlock_users" = "yes" ];then
  echo "IMPORTANT:DETS USERS TO BE ${u_action}ED WILL BE TAKEN FROM TICKETS IN TESTING"
fi

echo ""

jira_issues=$(jira_get_issues_by_deployment_status $deployment_id "$issue_status")

echo "*****TICKETS WHICH ARE CURRENTLY IN TESTING ON $deployment_id*****"

if [ -z "$jira_issues" ];then
  echo "NO TICKETS ARE CURRENTLY IN TESTING"
else
  echo "$jira_issues"
fi

echo ""

if [ "$users" = "none" ];then
  users=$(echo "$jira_issues" | awk -F',' '{print $1}' | sed 's/"//g')
fi
echo "*****GETTING HOSTNAMES OF LMS AND WORKLOAD VM*****"

if [ $deployment_type = "pENM" ];then

  lms_ip=$(dmt_get_lms_ip $deployment_id)
  lms_host=$(get_hostname_from_ip $lms_ip)
  echo ">>>LMS HOSTNAME: $lms_host"
else
  echo ">>>LMS IS NOT AVAILABLE FOR THIS DEPLOYMENT TYPE"
fi
workload_host=$(dmt_get_workload_hostname $deployment_id)
echo ">>>WORKLOAD VM HOSTNAME: $workload_host"
echo ""

hosts="$workload_host $lms_host"

if [ $lock_unlock_users = "yes" ] && [ ! -z "$jira_issues" ];then
  if [ $action = "lock" ];then	
    body_txt="Access credentials for deployment $deployment_id have been temporary disabled due to maintenance or exclusive access. \nAccess credentials will be restored when activities will be completed"
  else
    body_txt="Access credentials for deployment $deployment_id have been restored."
  fi
  echo "*****EXECUTING $u_action OF DETS USERS*****"
  if [ ! "$discard_users" = "none" ];then
    new_users=$(list_drop_items "$users" "$discard_users")
    echo ">>>USERS $discard_users HAVE BEEN REMOVED FROM $u_action USERS LIST"
    users=$new_users
  fi  
  echo ">>>USERS WHICH ARE ${u_action}ED:" $users
  for host in $hosts;do  
    for user in $users;do
      if host_user_exist $host $user;then
        echo ">>>${u_action}ING USER $user ON HOST $host"
        if host_lock_user $host $user $action;then
          echo "USER $user HAS BEEN SUCCESSFULLY ${u_action}ED"
	  set -x
	  if jira_post_comment $user "$body_txt";then
            echo "COMMENT HAS BEEN ADDED TO JIRA TICKET $user"
	  else
	    echo "FAILED TO ADD COMMENT TO JIRA TICKET $user"
	  fi
	  set +x
        else
          echo "ERROR:USER $user HAS NOT BEEN SUCCESSFULLY ${u_action}ED"
        fi
      else
        echo ">>>USER $user IS NOT PRESENT IN HOST $host!"
      fi
    done
  done 
  echo ""  
fi

testing_users=$(echo "$jira_issues" | awk -F',' '{print $1}' | sed 's/"//g')

if [ "$remove_unused_dets_users" = "yes" ];then
  for host in $hosts;do
    dets_users_active=$(host_get_users_by_key $host DETS)
    echo "*****CHECKING PRESENCE OF UNUSED DETS USERS IN HOST $host*****"
    echo ">>>DETS USERS WHICH ARE ACTIVE IN HOST $host: $dets_users_active"
    users_to_remove=$(list_drop_items "$dets_users_active" "$testing_users")
    if [ ! -z "$users_to_remove" ];then
      echo ">>>USERS WHICH HAVE BEEN LEFT (NOT IN TESTING TICKETS): $users_to_remove"
      echo ""
      for user in $users_to_remove;do
        echo "DELETING USER $user"
        if host_delete_user $host $user;then
	  echo "USER $user HAS BEEN SUCCESSFULLY DELETED"
	else
	  echo "ERROR:USER $user HAS NOT BEEN DELETED!"
	fi
      done	
    else
      echo ">>>NO DETS USERS LEFT HAVE BEEN FOUND ON HOST $host"
    fi
    echo ""
  done
fi

