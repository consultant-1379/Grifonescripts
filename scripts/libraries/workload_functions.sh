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

workload_upgrade_torutil_rpm(){

local workload_host=$1 torutil_version=$2

if host_ssh_cmd $workload_host "/opt/ericsson/enmutils/.deploy/update_enmutils_rpm $torutil_version";then
  return 0
else
  return $?
fi

}

