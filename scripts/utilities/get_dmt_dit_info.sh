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

. ../libraries/dmt_dit_functions.sh
. ../libraries/generic_functions.sh

deployment_id=$1
deployment_type=$2
selection=$3

if [ $deployment_type = "pENM" ];then
  case "$selection" in

  lms|LMS)
    lms_ip=$(dmt_get_lms_ip $deployment_id)
    lms_host=$(get_hostname_from_ip $lms_ip)
    echo $lms_host
    ;;
  workload|WORKLOAD)
    wkl_vm=$(dmt_get_workload_hostname $deployment_id)
    echo $wkl_vm
    ;;
  netsim|NETSIM)
    netsims=$(dmt_get_netsims_hostname $deployment_id)
    echo $netsims
    ;;
  *)
    echo "Wrong selection $selection !"
    exit 1
   ;;
  esac
else
  case "$selection" in

  workload|WORKLOAD)
    wkl_vm=$(dit_get_workload_vm_hostname)
    echo $wkl_vm
    ;;
  netsim|NETSIM)
    netsims=$(dit_get_netsim_hostnames) 
    echo $netsims
    ;;
  *)
    echo "Wrong selection $selection !"
    exit 1
   ;;
  esac
fi

