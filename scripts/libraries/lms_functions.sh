#!/bin/bash
# Functions to execute cmd on lms
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
# Purpose : This library contains functions used to execute commands on lms
#
#
# Version Information:
#       Version Who             Date            Comment
#       0.1     estmann         26/04/2023      Initial draft
#
# Usage   : 
#
# ********************************************************************

#readonly JIRA_USER='S4_Team'


#lms_ssh_cmd(){

#local lms_host=$1 cmd=$2 cmd_out

#cmd_out=$(ssh root@$lms_host "$cmd")

#echo "$cmd_out"

#}

lms_get_snap_rpm(){

local lms_host=$1 snap_rpm

#snap_rpm=$(lms_ssh_cmd $lms_host "find /var/www/html | grep SNAP")
snap_rpm=$(host_ssh_cmd $lms_host "find /var/www/html | grep SNAP")

echo "$snap_rpm" | grep -o -P 'ERIC[^\\]*rpm'

}

lms_get_enm_iso(){

local lms_host=$1 enm_iso

enm_iso=$(host_ssh_cmd $lms_host "cat /etc/enm-version")

echo $enm_iso
}

lms_get_enm_vm_names(){

local lms_host=$1 enm_vm_names

enm_vm_names=$(host_ssh_cmd $lms_host "/opt/ericsson/enminst/bin/vcs.bsh --groups | grep vm | awk '{print \$2}' | sort | uniq | sed -e 's/Grp_CS_.*_cluster_//g; s/_/-/g'")

echo $enm_vm_names
}

lms_get_vm_by_name(){

local lms_host=$1 vm_name=$2 enm_vms	

#enm_vms=$(host_ssh_cmd $lms_host "cat /etc/hosts | grep -E '\\${vm_name}(\s|$)' | awk '{print \$2}'")
enm_vms=$(host_ssh_cmd $lms_host "cat /etc/hosts | grep -E '${vm_name}(\s|$)' | awk '{print \$2}'")
echo $enm_vms
}

lms_execute_vm_cmd(){
local lms_host=$1 vm_name=$2 cmd=$3 cmd_out

cmd_out=$(host_ssh_cmd $lms_host "/root/rvb/bin/ssh_to_vm_and_su_root.exp $vm_name '$cmd'" | sed 's/\r//')

echo $cmd_out
}

lms_get_enm_systems(){
local lms_host=$1 enm_systems

enm_systems=$(host_ssh_cmd $lms_host "/opt/ericsson/enminst/bin/vcs.bsh --systems | grep cluster | awk '{print \$1\"|\"\$3}'")

echo $enm_systems
}

lms_create_rpm_installed_file(){

local lms_host=$1 vms=$2 enm_systems=$3 file=$4 vm rpm_list rpm_list1 rpm_list2 counter total_vms host hosts

#total_vms=$(echo $vms | wc -w)
#counter=0
echo "" > $file
hosts="$vms $lms_host $enm_systems"

for host in $hosts;do
#  echo "VM: $vm"
#  rpm_list=$(lms_execute_vm_cmd $lms_host $vm "rpm -qa" | grep -oP "ERIC[^ ]+;rpm -qa" | grep -oP "EXTR[^ ]+")
  if [[ "$vms" == *"$host"* ]] || [[ "$enm_systems" == *"$host"* ]];then
    rpm_list=$(lms_execute_vm_cmd $lms_host $(echo $host | awk -F'|' '{print $1}') "rpm -qa")
  else
    rpm_list=$(host_ssh_cmd $lms_host "rpm -qa")
  fi
  rpm_list1=$(echo "$rpm_list" | grep -oP "ERIC[^ ]+")
  rpm_list2=$(echo "$rpm_list" | grep -oP "EXTR[^ ]+")
  rpm_list="$rpm_list1 $rpm_list2"
#  echo $rpm_list | grep -oP "ERIC[^ ]+"
#  echo $rpm_list
  for rpm in $rpm_list;do
    echo "$host $rpm" >> $file
  done
#  counter=$(( counter + 1 ))
#  show_progress $counter $total_vms
done
}
