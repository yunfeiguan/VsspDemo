#!/bin/bash 

FILE_PATH=$1
LOG_PATH=$2

for i in `seq 1 5`
do 
{
        rm -rf ${LOG_PATH}/test_${i}.log
	fio -filename=${FILE_PATH}/$(hostname -f)_$i -iodepth 1 -thread -rw=read -ioengine=psync -bs=128k -size=25G -numjobs=16 -runtime=2000 -group_reporting -name=mytest_$(hostname -f)_$i 2>&1 | tee -a ${LOG_PATH}/test_${i}.log 
}&
done && wait
