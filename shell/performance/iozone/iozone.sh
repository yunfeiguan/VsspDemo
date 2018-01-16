#!/bin/bash 

#if [ $# -lt 0 ];then
#    echo "Usage: sh $0 log_path"
#    exit 1
#fi
#MOUNT_POINT="/mnt/anna-fuse/test_fio"
MOUNT_POINT="/mnt/anna-fuse/iozone_test"
LOG_PATH="/home/log/iozone_test"


#for i in `seq 1 2`
#do 
#{
i=1
echo > ${LOG_PATH}/$(hostname -f)_${i}_output_4k.txt
iozone -w -Rb ${LOG_PATH}/$(hostname -f)_${i}_spreadsheet_output_4K.wks -t 32 -F \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
${MOUNT_POINT}/$(hostname -f)_$i \
-O -i0 -i2 -+n -r 4K -s 64G 2>&1 | tee -a ${LOG_PATH}/$(hostname -f)_${i}_output_4k.txt
#}
#done
#&
#done && wait
