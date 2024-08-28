#!/bin/bash

ticket_query="$1"
watchers=$2
ticket_users=$3
ticket_status=$4
deployment_ids=$5
type_of_server_access=$6


JIRA_CURL_CMD='sudo curl -s -u MBTGWBYEBQ:UADyaxhCDYekTcge3zHck8km -X GET -H "Content-Type: application/json"'
JIRA_JQL_URL="https://eteamproject.internal.ericsson.com/rest/api/2/search?jql="
JIRA_REST_URL_ISSUE="https://eteamproject.internal.ericsson.com/rest/api/2/issue/"


ticket_status=$(echo "$ticket_status" | sed 's/ /%20/g' | sed "s/,/\',\'/g")
type_of_server_access=$(echo "$type_of_server_access" | sed 's/ /%20/g' | sed "s/,/\',\'/g")

getJiraTickets(){
  local jira_tickets jira_query
  if [ ! -z "$deployment_ids" ];then
    deployment_query_to_add=$(addDeploymentsToQuery)
  fi
  if [ ! -z "$ticket_status" ];then
    status_query_to_add=$(addTicketStatus $ticket_status)
    status_in_ticket_query=$(echo $ticket_query | grep -o -P "status.*")
    if [ ! -z "$status_in_ticket_query" ];then
      ticket_query=$(echo $ticket_query | sed "s/%20AND%20$status_in_ticket_query//g")
    fi	    
  fi
  if [ ! -z "$type_of_server_access" ];then
    type_of_server_access_query_to_add=$(addTypeOfServerAccessToQuery)
  fi

  jira_query="$JIRA_CURL_CMD $JIRA_JQL_URL$ticket_query$deployment_query_to_add$status_query_to_add$type_of_server_access_query_to_add&maxResults=100"
  jira_tickets=$($jira_query | jq -r '.issues[].key')
  if [ $? -ne 0 ];then
    exit 1
  else  
    echo "$jira_tickets"
  fi  
}

addTypeOfServerAccessToQuery(){
 
  type_server_access_query="%20AND%20'cf\[35826\]'%20IN%20('$type_of_server_access')"
#  type_server_access_query="%20AND%20'cf\[25604\]'%20IN%20('$type_of_server_access')"
#  type_server_access_query="%20AND%20'Type%20of%20Server%20Access'%20IN%20('$type_of_server_access')"
#  %20AND%20'\''Type%20of%20Server%20Access'\''%20in%20(Shared,%20'\''Exclusive'\'
  echo $type_server_access_query
}


addDeploymentsToQuery(){
  deployment_query="%20AND%20("
  deployment_ids=$(echo $deployment_ids | sed 's/,/ /g')
  num=$(echo $deployment_ids | wc -w)
  if [ $num -eq 1 ];then
    deployment_query="${deployment_query}environment%20~%20$deployment_ids)"
  fi
  if [ $num -gt 1 ];then
    for deployment_id in $deployment_ids;do
      deployment_query="${deployment_query}environment%20~%20$deployment_id"
      i=$((i+1))
      if [ $i -lt $num ];then
        deployment_query="${deployment_query}%20OR%20"
      fi
    done 
    deployment_query="${deployment_query})"
  fi
  echo $deployment_query
}  

addTicketStatus(){
#  %20AND%20Status%20NOT%20IN%20(Closed,%20Resolved,%20Done)"
  local ticket_status=$1 status_query
  status_query="%20AND%20Status%20IN%20('$ticket_status')"
  echo $status_query
}

getEmailAddressesFromJiraTicket(){
  local jira_ticket=$1
  local ticket_users=$2
  local ticket_status=$3
  local JIRA_QUERY email_address email_address_reporter email_address_assignee
  if [[ "$watchers" == "yes" ]];then
    JIRA_QUERY="$JIRA_CURL_CMD $JIRA_REST_URL_ISSUE$jira_ticket/watchers"
    email_address_watchers=$($JIRA_QUERY | jq -r '.watchers[].emailAddress')
  fi
  JIRA_QUERY="$JIRA_CURL_CMD $JIRA_REST_URL_ISSUE$jira_ticket"
  if [[ "$ticket_users" == *"Reporters"* ]]; then
      email_address_reporter=$($JIRA_QUERY | jq -r '.fields.reporter.emailAddress')
  fi
  if [[ "$ticket_users" == *"Assignees"* ]]; then
      email_address_assignee=$($JIRA_QUERY | jq -r '.fields.assignee.emailAddress')
  fi
  email_address="$email_address_watchers $email_address_reporter $email_address_assignee"
  echo "$email_address"

}

jira_tickets=$(getJiraTickets)

for jira_ticket in $jira_tickets;do
  email_address=$(getEmailAddressesFromJiraTicket $jira_ticket $ticket_users $ticket_status)
  email_addresses="$email_addresses $email_address"
done

email_addresses=$(echo $email_addresses | sed 's/^ *//g' | tr ' ' '\n' | sort | uniq | tr '\n' ' ')

echo $email_addresses
