#!/bin/bash
# Functions to access Jira data
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
           # Name    : jira_functions.lib
# Date    : 26/04/2023
# Revision: A
# Purpose : This library contains functions used to access Jira data
#
#
# Version Information:
#       Version Who             Date            Comment
#       0.1     estmann         26/04/2023      Initial draft
#
# Usage   :
#
# ********************************************************************

lms_host=$1
deployment_id=$2

ombs_hosts=$(ssh -q root@$lms_host "cat /etc/hosts" | grep ombs | grep bk | awk '{print $2}')

for ombs_host in $ombs_hosts;do
  ombs_hostname_cmd=$(ssh -q root@$lms_host "timeout 5s ssh -q root@$ombs_host 'hostname'") 
  if [ ! -z "$ombs_hostname_cmd" ];then
    break
  fi
done

lms_host_img=$(echo $lms_host | awk -F '-' '{print $1}')

#ombs_image=$(ssh -q root@$lms_host "ssh -q root@$ombs_host 'bppllist'" | grep SCHEDULED | grep $lms_host | sed 's/ENM_SCHEDULED_//g')
ombs_image=$(ssh -q root@$lms_host "ssh -q root@$ombs_host 'bppllist'" | grep SCHEDULED | grep $lms_host_img | sed 's/ENM_SCHEDULED_//g')


ombs_bkps=$(ssh -q root@$lms_host "ssh -q root@$ombs_host '/ericsson/ombss_enm_$deployment_id/ombss_enm/bin/manage_backup_images.bsh -M $ombs_image -s'" | grep $ombs_image | awk '{print $3" "$4" "$5" "$6" "$7" "$8}')

if [ -z "$ombs_bkps" ];then
  ombs_bkps="Ombs backup not present"
else
  ombs_bkps=$(echo "$ombs_bkps" | tr '\n' '|')
fi	

echo $ombs_bkps
