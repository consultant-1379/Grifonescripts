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
# Name    : black_rpm_verification.sh
# Date    : xx/xx/2023
# Revision: A
# Purpose : This script is used to provide a report about black (SNAPSHOT)
#           rpm present in Physical Deployments
#
# Version Information:
#       Version Who               Date            Comment
#       0.1     estmann/egarmau   xx/xx/2023      Initial draft
#
# Usage   :
#
# ********************************************************************

. ../libraries/host_functions.sh
. ../libraries/jira_functions.sh
. ../libraries/dmt_dit_functions.sh
. ../libraries/generic_functions.sh
. ../libraries/lms_functions.sh
. ../libraries/ciportal_functions.sh

deployment_id=$1
deployment_type=$2
kgb_rpm_jira_ticket=$3
kgb_rpm=$4

kgb_rpm_list=$(echo $kgb_rpm |tr '@@' '\n' | awk -F '::' '{print $2}' | grep -o -P "ERIC.*\\.rpm")

banner "GRIFONE BLACK RPM VERIFICATION"
echo ""
echo "*****SUMMARY OF OPTIONS*****"
echo "DEPLOYMENT_ID:" $deployment_id
echo "DEPLOYMENT TYPE:" $deployment_type
echo "KGB RPM JIRA TICKET: $kgb_rpm_jira_ticket"
echo "KGB RPM:"
echo $kgb_rpm_list | tr ' ' '\n'
echo ""
echo "*****GETTING HOSTNAME OF LMS*****"
if [ $deployment_type = "pENM" ];then
  lms_ip=$(dmt_get_lms_ip $deployment_id)
  lms_host=$(get_hostname_from_ip $lms_ip)
  echo ">>>LMS HOSTNAME: $lms_host"
else
  echo ">>>LMS IS NOT AVAILABLE FOR THIS DEPLOYMENT TYPE"
fi
echo ""
echo "*****SEARCHING SNAPSHOT RPM PRESENT IN LMS*****"
snap_rpm_list=$(lms_get_snap_rpm $lms_host)
snap_rpm_list=$(echo $snap_rpm_list | tr ' ' '\n' | sort | uniq)
echo "$snap_rpm_list"
if [ -z "$snap_rpm_list" ];then
  echo ">>>THERE ARE NO SNAPSHOT RPM TO REMOVE!"
  exit 0
fi
echo ""
jira_testing_full=$(jira_get_issues_by_deployment_status $deployment_id "Testing")
jira_testing=$(echo "$jira_testing_full" | awk -F '","' '{print $1}' | sed 's/"//g')
jira_resolved_full=$(jira_get_issues_by_deployment_status $deployment_id "Resolved")
jira_resolved=$(echo "$jira_resolved_full" | awk -F '","' '{print $1}' | sed 's/"//g')
echo "*****JIRA TICKETS IN TESTING STATE*****"
for jira in $jira_testing;do
  jira_info_testing=$(get_issue_info $jira)
  jira_info_testing_sum="$jira_info_testing_sum\n$jira_info_testing"
done
jira_tickets_testing_info=$(echo -e $jira_info_testing_sum)
echo "$jira_tickets_testing_info"
echo ""
echo "*****JIRA TICKETS IN RESOLVED STATE*****"
for jira in $jira_resolved;do
  jira_info_resolved=$(get_issue_info $jira)
  jira_info_resolved_sum="$jira_info_resolved_sum\n$jira_info_resolved"
done
jira_tickets_resolved_info=$(echo -e $jira_info_resolved_sum)
echo "$jira_tickets_resolved_info"
echo ""
#echo "*****CHECKING IF SNAPSHOTS RPM ARE PRESENT IN TESTING/RESOLVED TICKETS*****"
rpms_to_remove=""
for snap_rpm in $snap_rpm_list;do
  echo $snap_rpm
#  rpm_is_present=""
  rpm_not_removed=0
  rpm_not_found=0
  echo "*****CHECKING IF SNAPSHOTS RPM ARE PRESENT IN TESTING TICKETS*****"
  for jira in $jira_testing;do
    rpm_info_ticket=$(get_rpm_info_from_jira_ticket $jira)
    rpm_info=$(grep_string_between "$rpm_info_ticket" 'ERIC' '.rpm')
    if [[ $rpm_info == *"$snap_rpm"* ]];then
#      rpm_is_present="1"
      echo -e ">>>RPM $snap_rpm PRESENT IN TESTING TICKET $jira -> \033[0;32mRPM REMOVAL NOT NEEDED\033[0m"
      rpm_not_removed=1
      break
    fi
  done
#  echo $rpm_not_removed
#  if [ -z "$rpm_not_removed" ];then
  if [ $rpm_not_removed -eq 0 ];then
    echo "*****CHECKING IF SNAPSHOTS RPM ARE PRESENT IN RESOLVED TICKETS*****"
    for jira in $jira_resolved;do
      rpm_info_ticket=$(get_rpm_info_from_jira_ticket $jira)
      rpm_info=$(grep_string_between "$rpm_info_ticket" 'ERIC' '.rpm')
#      set -x
      if [[ $rpm_info == *"$snap_rpm"* ]];then
        echo -e ">>>RPM $snap_rpm PRESENT IN RESOLVED TICKET $jira -> \033[0;31mRPM HAS TO BE REMOVED!\033[0m"
        rpms_to_remove="$rpms_to_remove $snap_rpm"
	rpm_not_found=1
	break
#      else
#        rpm_not_found=0
      fi
#      set +x
    done
  fi
#  echo "rpm_not_removed $rpm_not_removed"
#  echo "rpm_not_found $rpm_not_found"
#  if [ ! -z "$rpm_not_found" ];then
   if [ $rpm_not_removed -eq 0 ] && [ $rpm_not_found -eq 0 ];then
     echo -e ">>>RPM $snap_rpm NOT PRESENT IN TESTING/RESOLVED TICKETS -> \033[0;31mRPM HAS TO BE REMOVED!\033[0m"
     rpms_to_remove="$rpms_to_remove $snap_rpm"
   fi
done
if [ -z "$rpms_to_remove" ];then
  echo ">>>THERE ARE NO RPM TO REMOVE!"
  exit 0
fi
echo "*****CREATING FILE WITH LIST OF ENM RPM*****"
enm_vm_names=$(lms_get_enm_vm_names $lms_host)
echo ">>>GETTING LIST OF ENM VMs"
for vm_name in $enm_vm_names;do
  if vm=$(lms_get_vm_by_name $lms_host $vm_name | awk '{print $1}');then
    vms="$vms $vm"
  else
    echo ">>>ERROR GETTING VM WITH NAME $vm_name"
  fi
done
echo ">>>GETTING LIST OF ENM SYSTEMS"
if ! enm_systems=$(lms_get_enm_systems $lms_host);then
  echo ">>>ERROR GETTING LIST OF ENM SYSTEMS"
fi
rpm_file="files/${deployment_id}_rpm_installed.txt"
echo ">>>FILE CREATION IS IN PROGRESS (TAKES SOME MINUTES TO COMPLETE)"
if lms_create_rpm_installed_file $lms_host "$vms" "$enm_systems" $rpm_file;then
  echo "FILE WITH LIST OF INSTALLED RPM HAS BEEN SUCCESSFULLY COMPLETED"
else
  echo "ERROR CREATING FILE WITH LIST OF INSTALLED RPM"
fi
echo ""
echo "*****GETTING INFO ABOUT RPM LINKS FOR REMOVAL*****"
enm_version=$(lms_get_enm_iso $lms_host)
enm_iso=$(echo $enm_version | awk '{print $5}' | sed 's/)//g')
echo ">>>ENM VERSION $enm_iso IS LOADED IN LMS"
echo ""
echo "========================================================RPM REMOVAL REPORT========================================================"
for rpm_to_remove in $rpms_to_remove;do
  rpm_name=$(echo $rpm_to_remove | awk -F'-' '{print $1}')
  ciportal_rpm_info=$(ciportal_get_enm_iso_package_url $enm_iso $rpm_name)
  sg_restart=$(grep $rpm_name $rpm_file | awk '{print $1}')
  echo $rpm_to_remove 
  echo "ISO Rpm Nexus Link: $ciportal_rpm_info"
  echo "VM/Hosts: $sg_restart"
  echo "----------------------------------------------------------------------------------------------------------------------------------"
done
echo "=================================================================================================================================="

