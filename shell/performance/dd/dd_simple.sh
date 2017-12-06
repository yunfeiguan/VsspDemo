#!/bin/bash 

FILE_PATH=$1
LOG_PATH=$2

for i in `seq 1 5`
do 
{
        rm -rf ${LOG_PATH}/dd_${i}.log
	dd  if=${FILE_PATH}/$(hostname -f)_$i of=/dev/null bs=128k count=25000 2>&1 | tee -a ${LOG_PATH}/dd_${i}.log 
}&
done && wait
