#!/bin/bash

. ../libraries/host_functions.sh
. ../libraries/jira_functions.sh
. ../libraries/dmt_dit_functions.sh
. ../libraries/generic_functions.sh
. ../libraries/lms_functions.sh

deployment_id=$1
deployment_type=$2
users=$3

echo "DEPLOYMENT_ID:" $deployment_id
echo "DEPLOYMENT TYPE:" $deployment_type
echo "USERS: $users"
echo ""

if [ $deployment_type = "pENM" ];then

  lms_ip=$(dmt_get_lms_ip $deployment_id)
  lms_host=$(get_hostname_from_ip $lms_ip)
  echo "LMS HOSTNAME: $lms_host"
else
  echo "LMS IS NOT AVAILABLE FOR THIS DEPLOYMENT TYPE"
fi

workload_host=$(dmt_get_workload_hostname $deployment_id)
echo "WORKLOAD VM HOSTNAME: $workload_host"
echo ""

hosts="$lms_host $workload_host"

for user in $users;do
  echo "*****CREATING USER $user ON LMS AND WORKLOAD VM*****"
  password_a=$(gpg --gen-random --armor 1 10)
  password_b=$(($RANDOM%10))
  password="$password_a$password_b"
  echo "PASSWORD: $password"
  for host in $hosts;do
    if host_ssh_cmd $host "useradd -g testers -m $user";then
      echo "USER $user HAS BEEN SUCCESSFULLY CREATED ON $host"
    else
      echo "ERROR: CREATION OF $user ON HOST $host HAS FAILED!"
    fi

    if host_ssh_cmd $host "echo $password | passwd --stdin $user";then
      echo "PASSWORD HAS BEEN SUCCESSFULLY ASSIGNED TO $user ON $host"
    else
      echo "ERROR: ASSIGNMENT OF PASSWORD TO $user ON HOST $host HAS FAILED!"
    fi
    echo ""
  done
done



