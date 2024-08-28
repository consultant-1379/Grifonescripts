#!/bin/bash

get_enm_iso() {
  if [ "$deployment_type" == "pENM" ];then
	enm_iso_version=$(ssh -q root@$msip "timeout 30 /opt/ericsson/enminst/bin/enm_version.sh" | grep ENM | grep "ISO Version" | head -1 | sed 's/ENM Version info      : //g')
	if [ -z "$enm_iso_version" ];then
		enm_iso_version="N/A"
	fi
  elif [ "$deployment_type" == "sENM" ];then
	IP=$(timeout 30 sshpass -p 12shroot ssh -q root@$wkl_vm 'env|grep EMP| cut -d'=' -f 2' )
	
	enm_iso_version=$(timeout 30 sshpass -p 12shroot ssh -q -t root@$wkl_vm "ssh -q -t -o StrictHostKeyChecking=no -i /var/tmp/enm_keypair.pem cloud-user@${IP} 'sudo consul kv get enm/deployment/enm_version'")
	if [ -z "$enm_iso_version" ];then
		enm_iso_version="N/A"
	fi
  elif [ "$deployment_type" == "cENM" ];then
	enm_iso_version=$(ssh -q -tt root@$wkl_vm "kubectl exec -it -n enm297 deploy/troubleshooting-utils -- bash -c 'cat /enm/.enm-version'")
        if [ -z "$enm_iso_version" ];then
                enm_iso_version="N/A"
        fi
  fi
  
#	if [[ ${#enm_iso_version} -gt 20 ]];then
	
#		enm_iso_version=$(echo "echo $enm_iso_version | awk '{print $NF}'")  
		
#	fi
#	if [[ ${#enm_iso_version} -gt 20 ]];then
#		enm_iso_version="Not_Found"
#	fi
#	enm_iso_version=${enm_iso_version%")"}
}

get_nss_utils() {
  if [ "$deployment_type" == "pENM" ];then
    nss_utils_version=$(ssh -q root@$msip "rpm -qa | grep ERICTWnssutils_CXP9036352" | awk -F "-" '{print $2}')
      if [ -z "$nss_utils_version" ];then
        nss_utils_version="ERROR"
      fi
  else
    nss_utils_version=$(ssh -q root@$wkl_vm "rpm -qa | grep ERICTWnssutils_CXP9036352" | awk -F "-" '{print $2}')
      if [ -z "$nss_utils_version" ];then
        nss_utils_version="ERROR"
      fi
  fi

}

get_torutils() {
	if [ "$deployment_type" == "pENM" ];then
		enm_torutils_version=$(ssh -q root@$msip rpm -qa | grep ERICtorutilities_CXP9030570 | awk -F "-" '{print $2}')
		if [ -z "$enm_torutils_version" ];then
			enm_torutils_version="ERROR"
		fi
	else 
		enm_torutils_version=$(ssh -q root@$wkl_vm rpm -qa | grep ERICtorutilities_CXP9030570 | awk -F "-" '{print $2}')
		if [ -z "$enm_torutils_version" ];then
			enm_torutils_version="ERROR"
		fi
	fi
}

get_torutils_int() {
  enm_torutils_int_version=$(sshpass -p 12shroot ssh -q root@$wkl_vm "rpm -qa | grep ERICtorutilitiesinternal_CXP9030579" | awk -F "-" '{print $2}')
  if [ -z "$enm_torutils_int_version" ];then
    enm_torutils_int_version="ERROR"
  fi


}


get_nss() {
  touch nss_version.txt
  for netsim in $netsims;do
  nss_version=$(sshpass -p 12shroot ssh -q root@$wkl_vm "sshpass -p netsim ssh -o StrictHostKeyChecking=no -q netsim@$netsim 'cat /netsim/simdepContents/nssProductSetVersion'" | awk -F "=" '{print $2}')
  if [ -z "$nss_version" ];then
    nss_version="ERROR"
  else
    echo $nss_version >> nss_version.txt
  fi
  done
  cat nss_version.txt  | sort | uniq > nss_version_sorted.txt
  nss=$(cat nss_version_sorted.txt  | tr '\n' ' ' | sed 's/|$//')
}

get_genstats() {
  touch genstats_version.txt
  for netsim in $netsims;do
  genstats_version=$(sshpass -p 12shroot ssh -q root@$wkl_vm "sshpass -p netsim ssh -o StrictHostKeyChecking=no -q netsim@$netsim '/netsim_users/pms/bin/genStatsRPMVersion.sh'" | awk -F "-" '{print $2}')  
  if [ -z "$genstats_version" ];then
    genstats_version="ERROR"
  else
    echo $genstats_version >> genstats_version.txt
  fi
done
  cat genstats_version.txt | sort | uniq > genstats_version_sorted.txt
  genstats=$(cat genstats_version_sorted.txt | tr '\n' ' ' | sed 's/|$//')
}

get_nrm() {
  touch nrm_info.txt
  for netsim in $netsims;do	
    nrm_info=$(sshpass -p 12shroot ssh -q root@$wkl_vm "sshpass -p netsim ssh -o StrictHostKeyChecking=no -q netsim@$netsim 'cat /netsim/simdepContents/NRMDetails'")
    nrm=$(echo "$nrm_info" | head -1 | awk -F "=" '{print $2}')
    nrm_module=$(echo "$nrm_info" | tail -1 | awk -F "=" '{print $2}')
    echo $nrm $nrm_module >> nrm_info.txt
#    if [ -z "$nrm" ];then
#      nrm="ERROR"
#    fi
  done 
  cat nrm_info.txt | sort -k 2 | uniq > nrm_info_sorted.txt
  nrm=$(cat nrm_info_sorted.txt | tr '\n' '|')
#  echo $nrm
}


get_synch_nodes() {
  no_synch_nodes=$(timeout 45 sshpass -p 12shroot ssh -q root@$wkl_vm "/opt/ericsson/enmutils/bin/cli_app 'cmedit get * CmFunction.syncStatus==SYNCHRONIZED -t'" | grep SYNCHRONIZED | wc -l)
  if [[ ! "$no_synch_nodes" =~ ^[0-9]+$ ]];then
    no_synch_nodes="ERROR"
  fi
  if [ -z "$no_synch_nodes" ];then
    no_synch_nodes="NULL"
  fi

}

get_all_nodes() {
  no_nodes=$(timeout 45 sshpass -p 12shroot ssh -q root@$wkl_vm "/opt/ericsson/enmutils/bin/cli_app 'cmedit get * CmFunction.syncStatus -t'" | grep instance | awk '{print $1}')
  if [[ ! "$no_nodes" =~ ^[0-9]+$ ]];then
    no_nodes="ERROR"
  fi
  if [ -z "$no_nodes" ];then
    no_nodes="NULL"
  fi

}

get_open_alarms() {
  no_open_alarms=$(timeout 45 sshpass -p 12shroot ssh -q root@$wkl_vm "/opt/ericsson/enmutils/bin/cli_app 'alarm get * -t'" | grep alarms | awk '{print $NF}')
  if [[ ! "$no_open_alarms" =~ ^[0-9]+$ ]];then
    no_open_alarms="ERROR"
  fi
  if [ -z "$no_open_alarms" ];then
    no_open_alarms="NULL"
  fi

}


msip=$1
wkl_vm=$2
netsims=$3
deployment_type=$4

get_enm_iso
get_nss_utils
get_torutils
get_torutils_int
get_nss
get_genstats
get_nrm
get_synch_nodes
get_all_nodes
get_open_alarms

#echo "ENM: $enm_iso_version NSSUTILS: $nss_utils_version TORUTILS: $enm_torutils_version TORUTILS_INT: $enm_torutils_int_version NSS: $nss GENSTATS: $genstats NRM: $nrm SYNCH_NODES: $no_synch_nodes"

echo "$no_synch_nodes|$no_nodes|$no_open_alarms|$enm_iso_version|$nss|$genstats|$nss_utils_version|$enm_torutils_version|$enm_torutils_int_version@@$nrm"
