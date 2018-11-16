#!/bin/bash

function is_service_exist()
{
    num=`ps -ef | grep check_waiting |grep -v grep|wc -l`

    if [ $num -eq 1 ];then
	echo 1
    elif [ $num -eq 0 ];then
	echo 0
    fi
}

function start_service()
{
    nohup sh /ws/check_waiting.sh &
}

while true
do
    exist=$(is_service_exist)

    if [ $exist -eq 0 ];then
	echo "start service"
	date
	start_service 
    else
	echo "service is well"
    fi	
    sleep 3600
done
