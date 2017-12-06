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
    result=`cat $LOG_FILE | grep copied |awk -F ' ' '{print $8}'`
    sum=$(echo "$sum+$result" |bc -l)
done
echo $sum
