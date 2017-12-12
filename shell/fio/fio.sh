#!/bin/bash 

if [ $# -lt 1 ];then
    echo "Usage: sh $0 log_path"
    exit 1
fi
MOUNT_POINT="/mnt/anna-fuse"
LOG_PATH=$1

for i in `seq 1 5`
do 
{
	fio -filename=${MOUNT_POINT}/$(hostname -f)_$i -direct=1 -iodepth 1 -thread -rw=read -ioengine=libaio -bs=128k -size=128G -numjobs=16 -runtime=2000 -group_reporting -name=mytest_$(hostname -f)_$i 2>&1 | tee -a ${LOG_PATH}/test_${i}.log 
}&
done && wait
