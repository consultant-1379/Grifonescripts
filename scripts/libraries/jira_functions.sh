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

readonly JIRA_USER='S4_Team'
readonly JIRA_PASSWORD='S4_Team'
readonly JIRA_ISSUE_URL='https://jira-oss.seli.wh.rnd.internal.ericsson.com/rest/api/2/issue/'
readonly JIRA_JQL_URL='https://jira-oss.seli.wh.rnd.internal.ericsson.com:443/rest/api/2/search?jql='

JIRA_CURL_GET="sudo curl -s -u $JIRA_USER:$JIRA_PASSWORD -X GET -H Content-Type:application/json"
JIRA_CURL_POST="sudo curl -s -u $JIRA_USER:$JIRA_PASSWORD -X POST -H Content-Type:application/json"

jira_post_comment(){

local jira_issue=$1 body_txt=$2

if $JIRA_CURL_POST -o /dev/null --data "{\"body\": \"$body_txt\"}" ${JIRA_ISSUE_URL}/${jira_issue}/comment;then
  return 0
else
  return 1
fi
}

jira_jql(){

local jql_query=$1 jira_return

jira_return=$($JIRA_CURL_GET $JIRA_JQL_URL$jql_query)

echo "$jira_return"

#REFER TO get_email_addresses_physical_dets.sh FOR EXAMPLES OF JSON DATA
}

jira_get_issue(){

local jira_issue=$1 jira_return

jira_return=$($JIRA_CURL_GET $JIRA_ISSUE_URL$jira_issue)

echo "$jira_return" | jq -r '.'

}

jira_get_issue_field(){
local jira_issue=$1 field=$2 jira_return

jira_return=$(jira_get_issue $jira_issue)

issue_field=$(echo $jira_return |  jq -r "$field")

echo "$issue_field"

}

get_rpm_info_from_jira_ticket(){
local jira_ticket=$1 issue_description

issue_description=$(jira_get_issue_field $jira_ticket ".fields.description")

echo "$issue_description" | grep 'ERIC' | grep 'rpm'

}

get_issue_info(){
local jira_ticket=$1 issue_info

issue_info=$(jira_get_issue_field $jira_ticket "[.key,.fields.summary,.fields.status.name] | @csv")

echo "$issue_info"

}

jira_get_issues_by_deployment_status(){
local deployment_id=$1 issue_status=$2 jql_grifone jql_query jira_return

jql_grifone="project=DETS%20AND%20component='Team%20Grifone'%20AND%20"
jql_deployment="environment~$deployment_id%20AND%20"

jql_issue_status=$(echo $issue_status | tr ' ' ',')

jql_issue_status="Status%20IN%20($jql_issue_status)"

jql_query=$jql_grifone$jql_deployment$jql_issue_status

#jira_return=$(jira_jql $jql_query | jq -r '.issues[].key')

jira_return=$(jira_jql $jql_query | jq -r ".issues[] | [.key,.fields.summary,.fields.status.name] | @csv")

echo "$jira_return"

#HOW TO TAKE MULTIPLE VALUES
# cat members | jq -r '[.login,.id] | @csv'
}

jira_get_issues_by_deployment_label(){
local label=$1 jql_query jira_return

jql_query="labels%20in%20($label)%20AND%20(status!=Closed%20AND%20status!=Done)"

jira_return=$(jira_jql $jql_query | jq -r ".issues[] | [.key,.fields.summary,.fields.status.name] | @csv")

echo "$jira_return"
}


