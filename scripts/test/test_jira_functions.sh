#!/bin/bash

. ../libraries/jira_functions_v1.sh
. ../libraries/lms_functions.sh
. ../libraries/generic_functions.sh

deployment_id='429'
#jql_query="project=DETS%20AND%20component='Team%20Grifone'%20AND%20environment~$deployment_id%20AND%20Status%20IN%20(Testing,Approved,Resolved)"
#jira_issue='DETS-14598'
issue_status='Testing'

#echo "***********TESTING JIRA_FUNCTIONS.SH*************"
#echo "***********FUNCTION: jira_jql"
#jira_jql $jql_query

#echo "***********FUNCTION: jira_get_issue"
#jira_get_issue $jira_issue

#echo "***********FUNCTION: jira_get_issue_field"
#jira_get_issue_field $jira_issue ".fields.description"

#echo "***********FUCTION: get_rpm_info_from_jira_ticket"
#rpm_info=$(get_rpm_info_from_jira_ticket $jira_issue)
#echo "$rpm_info"

#echo "***********FUCTION: get_issue_info"
#issue_info=$(get_issue_info $jira_issue)
#echo "JIRA TICKET INFO: $issue_info"

#echo "***********FUNCTION: jira_get_issues_by_deployment_status"
#echo "DEPLOYMENT ID: $deployment_id"
#echo "TICKET STATUS: $issue_status"
#jira_issues=$(jira_get_issues_by_deployment_status $deployment_id "$issue_status")
#echo "JIRA TICKETS FOUND:" 
#echo "$jira_issues"

#echo "***********FUNCTION: jira_post_comment"
#body_txt="THIS IS A MULTILINE \nTEXT COMMENT"

#jira_post_comment $jira_issue "$body_txt"

jira_issues=$(jira_get_issues_by_deployment_status $deployment_id "$issue_status")
