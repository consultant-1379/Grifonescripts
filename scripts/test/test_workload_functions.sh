#!/bin/bash

. ../libraries/host_functions.sh
. ../libraries/lms_functions.sh

deployment_id='429'
lms_host="ieatlms5735-1"
cmd="hostname"
user="pippo"

echo "***********TESTING WORKLOAD_FUNCTIONS.SH*************"
echo "***********FUNCTION: workload_upgrade_torutil_rpm"
workload_upgrade_torutil_rpm $workload_host $cmd

#echo "***********FUNCTION: lms_get_snap_rpm"
#snap_rpm=$(lms_get_snap_rpm $lms_host)
#echo "ENM SNAPSHOT RPM:" "$snap_rpm"

#echo "***********FUNCTION: lms_enable_disable_user"
#echo "LOCK USER: $user"
#lms_lock_user $lms_host $user lock



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


echo "***********FUNCTION: lms_get_enm_vm_names"
enm_vm_names=$(lms_get_enm_vm_names $lms_host)
echo "ENM VM NAMES:"
echo $enm_vm_names

#echo "***********FUNCTION: lms_get_vm_by_name"
#vms=$(lms_get_vm_by_name $lms_host "mscmce")
#echo "VM WITH NAME mscmce: $vms"

#echo "***********FUNCTION: lms_get_vm_rpm"
#rpm_list=$(lms_get_vm_rpm $lms_host "mscmce")
#echo "$rpm_list" | grep -oP "ERIC[^ ]+"

#enm_vm_names="mscm"

echo "" > pippo.txt
for vm_name in $enm_vm_names;do
  vm=$(lms_get_vm_by_name $lms_host $vm_name | awk '{print $1}')
  echo "VMNAME: $vm_name VM: $vm"
  rpm_list=$(lms_execute_vm_cmd $lms_host $vm "rpm -qa" | grep -oP "ERIC[^ ]+")
#  echo $rpm_list | grep -oP "ERIC[^ ]+"
  echo $rpm_list
  for rpm in $rpm_list;do
    echo "$vm_name $rpm" >> pippo.txt
  done
done

#echo "" > pippo.txt
#for rpm in $rpm_list;do
#  echo "$vm_name $rpm" >> pippo.txt
#done

cat pippo.txt
