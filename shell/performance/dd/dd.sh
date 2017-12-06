#!/bin/bash 

if [ $# -lt 3 ];then
    echo "sh $0 MOUNT_PREFIX DIR LOG_PATH"
    echo "exaple: sh $0 /mnt/anna-fuse fio /home/log"
    exit -1
fi
MOUNT_PREFIX=$1
DIR=$2
LOG_PATH=$3

for j in `seq 1 5`
do
{
    FILE_PATH=$MOUNT_PREFIX$j 
    echo $FILE_PATH
    for i in `seq 1 5`
    do 
    {
        rm -rf ${LOG_PATH}/dd_${j}_${i}.log
	echo ${FILE_PATH}/${DIR}/$(hostname -f)_$i
    	dd  if=${FILE_PATH}/${DIR}/$(hostname -f)_$i of=/dev/null bs=1M 2>&1 | tee -a ${LOG_PATH}/dd_${j}_${i}.log 
    }& done && wait
} & done && wait
