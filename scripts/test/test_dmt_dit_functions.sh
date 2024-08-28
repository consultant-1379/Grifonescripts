#!/bin/bash

. ../libraries/dmt_dit_functions.sh

deployment_id='429'

echo "***********TESTING DMT_DIT_FUNCTIONS.SH*************"
echo "***********FUNCTION: dmt_get_lms_ip"
lms_ip=$(dmt_get_lms_ip $deployment_id)
echo "LMS IP FOR DEPLOYMENT $deployment_id: $lms_ip"

echo "***********FUNCTION: dmt_get_workload_hostname"
workload_hostname=$(dmt_get_workload_hostname $deployment_id)
echo "WORKLOAD VM FOR DEPLOYMENT $deployment_id: $workload_hostname"
