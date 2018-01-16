#!/bin/bash

#if [ $# -lt 1 ]

#fi

LOG_PATH="/home/log/iozone_test"
random_read=0
readom_write=0
val=0

for i in `seq 1 5`
do
{
    read_val=`cat ${LOG_PATH}/$(hostname -f)_${i}_output_4k.txt | grep "Random read" | awk -F " " '{print $5}'`
    echo "`(hostname -f)`_${i} Random read $read_val"
    #((random_read+=${val}))
    ((random_read+=`echo ${read_val%.*}`))
}
done
echo $random_read

for i in `seq 1 5`
do
{
    write_val=`cat ${LOG_PATH}/$(hostname -f)_${i}_output_4k.txt | grep "Random write" | awk -F " " '{print $5}'`
    echo "`(hostname -f)`_${i} Random write $write_val"
    ((random_write+=`echo ${write_val%.*}`))
}
done
echo $random_write
