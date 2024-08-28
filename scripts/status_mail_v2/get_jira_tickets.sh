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
. ../libraries/jira_functions_v1.sh

deployment_id=$1
issue_status=$2

jira_issues=$(jira_get_issues_by_deployment_status $deployment_id "$issue_status")

if [ -z "$jira_issues" ];then
  echo "|NONE"
else
  jira_issues=$(echo "$jira_issues" | sed 's/"//g' | sed 's/@//g' | awk -F',' '{print "https://eteamproject.internal.ericsson.com/browse/"$1"|"$1":"$2"|"$4}' | tr '\n' '@' | sed 's/@$//')	
  echo "$jira_issues"
fi

