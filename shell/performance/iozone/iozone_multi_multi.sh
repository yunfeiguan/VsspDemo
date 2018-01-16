#!/bin/bash 

#if [ $# -lt 0 ];then
#    echo "Usage: sh $0 log_path"
#    exit 1
#fi

MOUNT_POINT="/mnt/anna-fuse"
LOG_PATH="/home/log/iozone_test"


for i in `seq 1 5`
do 
{
    echo > ${LOG_PATH}/$(hostname -f)_${i}_output_4k.txt
    iozone -w -Rb ${LOG_PATH}/$(hostname -f)_${i}_spreadsheet_output_4K.wks -t 3 -F \
     ${MOUNT_POINT}${i}/iozone_test2/$(hostname -f)_${i}_1\
     ${MOUNT_POINT}${i}/iozone_test2/$(hostname -f)_${i}_2\
     ${MOUNT_POINT}${i}/iozone_test2/$(hostname -f)_${i}_3\
    -O -i0 -i2 -+n -r 4K -s 10G 2>&1 | tee -a ${LOG_PATH}/$(hostname -f)_${i}_output_4k.txt
}&
done && wait
