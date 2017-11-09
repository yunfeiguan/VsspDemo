#!/bin/bash 

GRUB_FILE=$1

first_val=`cat $GRUB_FILE |grep linux16| head -1` 
second_val=`cat $GRUB_FILE |grep linux16| tail -1` 

echo "first : ${first_val}"
echo "second: ${second_val}"

sed -i "s#$first_val#$first_val ima_appraise=off#" $GRUB_FILE
sed -i "s#$second_val#$second_val ima_appraise=off#" $GRUB_FILE
