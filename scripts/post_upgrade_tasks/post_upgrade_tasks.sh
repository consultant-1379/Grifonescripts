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
action=$2
users="$3"
discard_users="$4"
issue_status="$5"

banner "LOCK/UNLOCK DETS USERS MANAGEMENT"

echo ""

banner "SUMMARY OF OPTIONS"

echo "DEPLOYMENT_ID:" $deployment_id
echo "ACTION:" $action
echo "DETS USERS:" $users
echo "DISCARD_DETS_USERS:" $discard_dets_users
echo "TICKET_STATUS" $issue_status
echo ""

jira_issues=$(jira_get_issues_by_deployment_status $deployment_id "$issue_status")

echo "TICKETS WHICH ARE CURRENTLY $issue_status IN $deployment_id"

echo "$jira_issues"

if [ "$users" = "none" ];then
  users=$(echo "$jira_issues" | awk -F',' '{print $1}' | sed 's/"//g')

  new_users=$(list_drop_items "$users" "$discard_users")

  echo "FOLLOWING USERS WILL BE LOCKED:" $new_users
  if [ ! "$discard_users" = "none" ];then
    echo "USERS $discard_users HAVE BEEN REMOVED FROM LOCK USERS LIST"
  fi
fi

echo "GETTING IP OF LMS AND HOSTNAME OF WORKLOAD VM"
lms_ip=$(dmt_get_lms_ip $deployment_id)
workload_hostname=$(dmt_get_workload_hostname $deployment_id)

echo "LMS IP: $lms_ip"
echo "WORKLOAD VM HOSTNAME: $workload_hostname"

exit

for user in $users;do
  echo "LOCK USER: $user"
  if host_lock_user $host $user lock;then
    echo "INFO - USER $user HAS BEEN SUCCESSFULLY LOCKED"
  else
    echo "ERROR - USER $user HAS NOT BEEN SUCCESSFULLY LOCKED"
  fi
done



#echo "***********FUCTION: get_rpm_info_from_jira_ticket"
#get_rpm_info_from_jira_ticket $jira_issue

#set -x
#echo "***********FUNCTION: jira_get_issues_by_deployment_status"
#jira_get_issues_by_deployment_status $deployment_id "Testing Approved"

#rpm_info=$(get_rpm_info_from_jira_ticket DETS-10801)

#echo "$rpm_info" 

#echo "$rpm_info" | grep -o -P 'ERIC[^\\]*rpm'

#lms_get_snap_rpm ieatlms3901

#jira_get_issues_by_deployment_status 429 "Testing Approved"

#rpm_list=$(lms_get_snap_rpm ieatlms5735-1)

#echo $rpm_list

#set -x
#jira_get_issues_by_deployment_status 429 "Testing Approved"

#echo $jira_issues

#exit

#for rpm in $rpm_list;do

#  for jira_issue in $jira_issues;do
#    rpm_info=$(get_rpm_info_from_jira_ticket $jira_issue)
#    if is_string_contained $rpm $rpm_info;then
#      echo "RPM $rpm IS PRESENT IN JIRA TICKET $jira_issue"
#    fi
#  done
#done
