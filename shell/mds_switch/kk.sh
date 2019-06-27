#!/bin/bash

function get_mdsnum()
{
        num=`ceph mds dump --cluster xtao | grep mds | grep seq | wc -l`
        echo $num
}

function get_active()
{
	active=`ceph mds dump --cluster xtao | grep mds |grep active |awk '{print $3}'`
	active=${active#*\'}
	active=${active%\'*}
	echo $active
}

function kill_mds()
{
	hostname=`hostname`
	echo "will kill mds.$1"
	if  [[ $hostname =~ $1 ]];then
		#echo $1
		ps -ef |grep ceph-mds| grep -v grep|awk '{print $2}' | xargs kill -9
	else
		#echo $1
		pid=`ssh $1 ps -ef |grep ceph-mds| grep -v grep|awk '{print $2}'`
		echo "will kill pid $pid"
		`ssh $1 kill -9 $pid`
	fi
}

function start_mds()
{
	echo "start mds.$1 ..."
	hostname=`hostname`
	if [ $hostname = $1 ];then
		/ws/ceph-mds -i $1 --pid-file /var/run/ceph/mds.${1}.pid -c /etc/ceph/xtao.conf --cluster xtao
	else
		ssh $1 /ws/ceph-mds -i $1 --pid-file /var/run/ceph/mds.${1}.pid -c /etc/ceph/xtao.conf --cluster xtao
	fi
}

function wait_seconds()
{
	for ((i=1; i<= $1; i++))
	{
		seconds=$[$1-$i+1]
		echo $seconds && sleep 1
	}
}
function wait_single_mds()
{
	while true
	do
		if [[ `get_mdsnum` -eq 1 ]];then
			break;
		else
			sleep 5;
		fi
	done
	echo "the cluster have only one  mds ..."
}
while true
do
        mds_num=`get_mdsnum`
	echo "mds_num $mds_num"
	active=""
        if [ $mds_num -eq 2 ];then
		while [[ $active = "" ]]
		do
			active=`get_active`
			sleep 3
		done
		echo "$active become active ...wait 5 senconds then kill it"
		sleep 5
		kill_mds $active
		if [ $? == 0 ];then
			echo "kill mds.$active success ..."
			wait_single_mds
			start_mds $active
			if [ $? == 0 ];then
				echo "start mds.$active success ..."
			else
				echo "start mds.$active failure, will exit ..."
				exit 0
			fi
		else
			echo "kill mds.$active failure, will exit"
			exit 0
		fi
	else
		wait_seconds 5
        fi
done
