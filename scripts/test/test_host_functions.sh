#!/bin/bash

. ../libraries/host_functions.sh

deployment_id='429'
host="ieatlms5735-1"
cmd="hostname"
user="pippo"

echo "***********TESTING HOST_FUNCTIONS.SH*************"
echo "***********FUNCTION: host_ssh_cmd"
host_ssh_cmd $host $cmd

#echo "***********FUNCTION: lms_get_snap_rpm"
#snap_rpm=$(lms_get_snap_rpm $lms_host)
#echo "ENM SNAPSHOT RPM:" "$snap_rpm"

echo "***********FUNCTION: lms_enable_disable_user"
echo "LOCK USER: $user"
host_lock_user $host $user lock



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
