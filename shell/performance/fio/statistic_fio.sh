#!/bin/bash

if [ $# -lt 3 ];then
    echo  "Usage: sh $0 file_prefix start end"
    exit 1
fi

FILE=$1
start=$2
end=$3
sum=0

for(( i=$start; i<=$end; i++ ))
do
    LOG_FILE=${FILE}_${i}.log
    echo "start deal with $LOG_FILE"
    result=`cat $LOG_FILE |grep READ | awk -F ' ' '{print $3}' | awk -F '=' '{print $2}'`
    ((sum+=`echo ${result%K*}`))
done
echo $sum
