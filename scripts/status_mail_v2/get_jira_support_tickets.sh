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

#deployment_id=$1
label=$1
add_jira_support_tickets=$2

#label="s4deploymentissue$deployment_id"

jira_support_issues=$(jira_get_issues_by_deployment_label $label)

if [ ! -z "$add_jira_support_tickets" ];then
  for add_jira_support_ticket in $add_jira_support_tickets;do
    jira_add_ticket_info=$(jira_get_issue_info $add_jira_support_ticket)
    if [ ! -z "$jira_add_tickets_info" ];then
      jira_add_tickets_info="$jira_add_tickets_info\n$jira_add_ticket_info"
    else
      jira_add_tickets_info="$jira_add_ticket_info"
    fi
  done
  jira_support_issues_add=$(echo -e $jira_add_tickets_info)
  if [ ! -z "$jira_support_issues" ];then
    jira_support_issues=$(echo -e "$jira_support_issues\n$jira_support_issues_add")
  else
    jira_support_issues="$jira_support_issues_add"
  fi
fi

if [ -z "$jira_support_issues" ];then
  echo "|NONE"
else
  jira_support_issues=$(echo "$jira_support_issues" | sed 's/"//g' | sed 's/@//g' | awk -F',' '{print "https://eteamproject.internal.ericsson.com/browse/"$1"|"$1":"$2}' | tr '\n' '@' | sed 's/@$//')
  echo "$jira_support_issues"
fi
