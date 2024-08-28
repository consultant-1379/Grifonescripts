#!/bin/bash

host_name=$1
nagios_host="atvts2505.athtem.eei.ericsson.se"
nagios_host_user="root"
nagios_host_password="shroot"
nagios_status_file="/usr/local/nagios/var/status.dat"
nagios_status_file_local="status.dat"
service_status_tmp_file_1="service_status_tmp_file_1_$host_name"
service_status_tmp_file_2="service_status_tmp_file_2_$host_name"
service_status_tmp_file_3="service_status_tmp_file_3_$host_name"
service_status_tmp_file_4="service_status_tmp_file_4_$host_name"
service_status_file="service_status_$host_name"

host_name=$(echo $host_name | awk -F'.' '{print $1}')

#rm -rf $nagios_status_tmp_file_1 $service_status_tmp_file_2 $service_status_tmp_file_3 $service_status_tmp_file_4 $service_status_file

#sshpass -p $nagios_host_password ssh $nagios_host_user@$nagios_host "grep -zPo \'servicestatus.{[^}]*host_name=$host_name-1[^}]*}\' $nagios_status_file" > $service_status_filename_full

sshpass -p $nagios_host_password scp -q $nagios_host_user@$nagios_host:$nagios_status_file $nagios_status_file_local

grep -zPo "servicestatus.{[^}]*host_name=$host_name[^}]*}" $nagios_status_file_local > $service_status_tmp_file_1

while IFS= read -r line; do
  if [[ "$line" == *"service_description"* ]] || [[ "$line" == *"plugin_output"* ]] || [[ "$line" == *"problem_has_been_acknowledged"* ]];then
    echo $line | sed '/long_plugin_output=/d' >> $service_status_tmp_file_2
  fi
done < "$service_status_tmp_file_1"

while read line1; do
  read line2
  read line3
  echo "$line1 - $line2 - $line3" >> $service_status_tmp_file_3
done < $service_status_tmp_file_2

cat $service_status_tmp_file_3 | grep -v "problem_has_been_acknowledged=1" | grep "CRITICAL" | sed 's/plugin_output=//g' | sed 's/service_description=//g' | sed 's/problem_has_been_acknowledged=0//g' > $service_status_tmp_file_4

while IFS= read -r line; do
    echo "${line}|" >> $service_status_file
done < "$service_status_tmp_file_4"

service_status=$(cat $service_status_file | tr '|' '\n' | awk -F'CRITICAL' '{print $2}' | tr '[:upper:]' '[:lower:]' | tr '\n' '|' | sed 's/- //g')

service_status=$(echo "$service_status" | sed 's/||/|/g')

count_nagios_checks=$(echo "$service_status" | tr '|' '\n' | wc -l)

if [ $count_nagios_checks -ge 20 ];then
  service_status="Too many critical Nagios issues reporting has been disabled"
fi

echo "$service_status"

