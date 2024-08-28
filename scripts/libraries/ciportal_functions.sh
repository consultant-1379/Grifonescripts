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

#readonly JIRA_USER='S4_Team'
#readonly JIRA_PASSWORD='S4_Team'
readonly CI_PORTAL_URL='https://ci-portal.seli.wh.rnd.internal.ericsson.com/'



#wget -q -O - --no-check-certificate --post-data="{\"isoName\":\"ERICenm_CXP9027091\",\"isoVersion\":\"2.25.27\",\"pretty\":true,\"showTestware\":false}" https://ci-portal.seli.wh.rnd.internal.ericsson.com/getPackagesInISO/


ciportal_get_enm_iso_packages(){
local enm_iso_version=$1 enm_iso_packages

enm_iso_packages=$(wget -q -O - --no-check-certificate --post-data="{\"isoName\":\"ERICenm_CXP9027091\",\"isoVersion\":\"$enm_iso_version\",\"pretty\":true,\"showTestware\":false}" ${CI_PORTAL_URL}getPackagesInISO/)

echo "$enm_iso_packages"

}

ciportal_get_enm_iso_package_url(){
  local enm_iso_version=$1 rpm_name=$2 enm_iso_packages url
  enm_iso_packages=$(ciportal_get_enm_iso_packages $enm_iso_version)
#  url=$(echo "$enm_iso_packages" | jq -r ".PackagesInISO[] | select(.name==\"$rpm_name\") | .url")
   url=$(echo "$enm_iso_packages" | jq -r ".PackagesInISO[] | select(.name==\"$rpm_name\") | [.url,.mediaCategory] | @csv")
  echo "$url"
}

