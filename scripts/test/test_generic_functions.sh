#!/bin/bash

. ../libraries/generic_functions.sh

echo "***********TESTING GENERIC_FUNCTIONS.SH*************"
echo "***********FUNCTION: is_string_contained"
str="bbbb"
substr="aaaa bbbb cccc"
if is_string_contained $str $substr;then
  echo "STRING $str IS CONTAINED INTO STRING $substr"
else
  echo "STRING $str IS NOT CONTAINED INTO STRING $substr"
fi

echo "***********FUNCTION: list_drop_items"
items="DETS-1234 DETS-5678 DETS-9012 DETS-9014"
drop="DETS-5678 DETS-9012"
echo "INITIAL LIST: $items"
echo "ITEMS TO DROP: $drop"
new_list=$(list_drop_items "$items" "$drop")
echo $new_list


