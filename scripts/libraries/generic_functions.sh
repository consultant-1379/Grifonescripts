#!/bin/bash
# Generic Functions
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
# Purpose : This library contains functions used to execute commands on lms
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


is_string_contained(){

local str=$1 substr=$2	

if [[ $str == *"$substr"* ]];
then
  return 0
else
  return 1
fi
}

list_drop_items(){

local list_items=$1 drop_items=$2

for drop_item in $drop_items;do

  list_items=$(echo $list_items | sed "s/$drop_item//g")
#  count_list_items=$(echo $list_items | wc -w)	
#  if [ $count_list_items -ne 1 ];then
#    list_items=$(echo $list_items | sed "s/$drop_item //g")
#  else
#    list_items=$(echo $list_items | sed "s/$drop_item//g")
#  fi
done

echo $list_items | sed 's/  //g'

}

list_add_items(){

local list_items=$1 add_items=$2	

#TO BE DONE	

}

banner() {
    msg="# $* #"
    edge=$(echo "$msg" | sed 's/./#/g')
    echo "$edge"
    echo "$msg"
    echo "$edge"
}

get_hostname_from_ip(){
local host_ip=$1 host_name

host_name=$(nslookup $host_ip | grep name | awk '{print $4}' | awk -F'.' '{print $1}')

echo $host_name
}

grep_string_between(){
local string="$1" initial=$2 final=$3 sub_string

sub_string=$(echo "$string" | grep -o -P "$initial.*\\${final}")

#echo $string | grep -o -P "ERIC.*rpm"
echo "$sub_string"

}

show_progress() {
local current="$1" total="$2" bar_size=40 bar_char_done="#" bar_char_todo="-" bar_percentage_scale=2

# calculate the progress in percentage
percent=$(bc <<< "scale=$bar_percentage_scale; 100 * $current / $total" )
# The number of done and todo characters
done=$(bc <<< "scale=0; $bar_size * $percent / 100" )
todo=$(bc <<< "scale=0; $bar_size - $done" )

# build the done and todo sub-bars
done_sub_bar=$(printf "%${done}s" | tr " " "${bar_char_done}")
todo_sub_bar=$(printf "%${todo}s" | tr " " "${bar_char_todo}")

# output the bar
#echo -ne "\rProgress : [${done_sub_bar}${todo_sub_bar}] ${percent}%"
echo "[${done_sub_bar}${todo_sub_bar}] ${percent}%"

#if [ $total -eq $current ]; then
#  echo -e "\nDONE"
#fi
}
