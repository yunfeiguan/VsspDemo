#!/bin/bash 

FILE_PATH=$1
LOG_PATH=$2

function usage () {
cat <<EOF
    Usage: $0 process_num file_path log_path 
    example: $0 1 /mnt/seven/ivan /home/log/
EOF
    exit 1
}
if [ $# -lt 3 ];then
    usage
fi
for i in `seq 1 5`
do 
{
    rm -rf ${LOG_PATH}/test_${i}.log
	fio -filename=${FILE_PATH}/$(hostname -f)_$i -iodepth 32 -thread -rw=read -ioengine=libaio -bs=4k -size=25G -numjobs=16 -runtime=2000 -group_reporting -name=mytest_$(hostname -f)_$i 2>&1 | tee -a ${LOG_PATH}/test_${i}.log 
}&
done && wait
