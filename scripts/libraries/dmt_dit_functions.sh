#!/bin/bash
# Functions to access DMT/DIT data
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
           # Name    : dmt_dit_functions.lib
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

#readonly JIRA_USER='S4_Team'
#readonly JIRA_PASSWORD='S4_Team'
#readonly JIRA_ISSUE_URL='https://jira-oss.seli.wh.rnd.internal.ericsson.com/rest/api/2/issue/'
#readonly JIRA_JQL_URL='https://jira-oss.seli.wh.rnd.internal.ericsson.com:443/rest/api/2/search?jql='

#DMT_TAF_PROPERTIES_GET="wget -q -O - --no-check-certificate 'https://ci-portal.seli.wh.rnd.internal.ericsson.com/generateTAFHostPropertiesJSON/?clusterId=$deployment_id&tunnel=true'"

#JIRA_CURL_GET="sudo curl -s -u $JIRA_USER:$JIRA_PASSWORD -X GET -H Content-Type:application/json"

dmt_get_hosts_props(){
local deployment_id=$1 dmt_reply

dmt_reply=$(sudo wget -q -O - --no-check-certificate "https://ci-portal.seli.wh.rnd.internal.ericsson.com/generateTAFHostPropertiesJSON/?clusterId=$deployment_id&tunnel=true")

echo "$dmt_reply"

}

dmt_get_lms_ip(){
local deployment_id=$1 lms_ip

lms_ip=$(dmt_get_hosts_props $deployment_id | jq -r '.[] | select(.hostname == "ms1").ip') 

echo $lms_ip

}

dmt_get_workload_hostname(){

local deployment_id=$1 workload_hostname

workload_hostname=$(dmt_get_hosts_props $deployment_id | jq -r '.[] | select(.type == "workload").hostname')

echo $workload_hostname

}

dmt_get_netsims_hostname(){

local deployment_id=$1 workload_hostname

netsim_vms=$(dmt_get_hosts_props $deployment_id | jq -r '.[] | select(.type == "netsim").hostname')

echo $netsim_vms
}

curl_api_cmd="http://atvdit.athtem.eei.ericsson.se/api/"

dit_get_document_id(){
  local document_type=$1
  local document_id
  document_id=$(curl -4 -s "${curl_api_cmd}deployments/?q=name=$deployment_id" | jq ".[].documents[] | select(.schema_name==\"$document_type\") | .document_id" | sed 's/"//g')
  echo $document_id
}

dit_get_workload_vm_hostname(){
  local vm_hostname
  local workload_doc_id
  workload_doc_id=$(dit_get_document_id "workload")
  vm_hostname=$(curl -4 -s "${curl_api_cmd}documents/$workload_doc_id" | jq '.content.vm[0].hostname' | sed 's/"//g')
  echo $vm_hostname
}

dit_get_netsim_hostnames(){
  local netsim_hostnames
  local netsim_doc_id
  netsim_doc_id=$(dit_get_document_id "netsim")
  netsim_hostnames=$(curl -4 -s "${curl_api_cmd}documents/$netsim_doc_id" | jq '.content.vm[].hostname' | sed 's/"//g')
  echo $netsim_hostnames
}

dit_get_netsim_ips(){
  local netsim_ips
  local netsim_doc_id
  netsim_doc_id=$(dit_get_document_id "netsim")
  netsim_ips=$(curl -4 -s "${curl_api_cmd}documents/$netsim_doc_id" | jq '.content.vm[].ip' | sed 's/"//g')
  echo $netsim_ips
}


