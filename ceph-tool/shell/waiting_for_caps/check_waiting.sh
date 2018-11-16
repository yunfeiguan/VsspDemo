#!/bin/bash

output_file="/tmp/.waiting_for_caps.log"
repaire_log="/tmp/.repaire_file.log"
log_file="/var/log/ceph/xtao-client.83822.log "
new_waitors=0
old_waitors=0
mount_point="/mnt/vol1"
py_cmd_path="/root/"

#tail -f /var/log/ceph/xtao-client.103163.log | grep \"waiting for caps need\"| tee -a output_file &

rm -rf $output_file
tail -f $log_file |grep --line-buffer "waiting for caps" >> $output_file & 

function get_waitors()
{
    num=`cat ${output_file} |grep "waiting for caps" | wc -l`
    echo $num
}

function get_backtrace()
{
    ino=`cat $output_file |grep "waiting for caps" | tail -n 1 | awk -F ' ' '{print $14}' | awk -F '.' '{print $1}'`
    echo "will decode $ino" >> $repaire_log
    rados -p cephfs_data getxattr ${ino}.00000000 parent --cluster xtao > /tmp/.parent
    if [ $? -eq 0 ];then
        ceph-dencoder import /tmp/.parent type inode_backtrace_t decode dump_json
        echo "decode $ino success" >> $repaire_log
    else
	echo -1;
        echo "will decode $ino fail" >> $repaire_log
    fi
}

function get_file()
{
    i=0
    tmp_file=""
    result=$(get_backtrace)
    if [[ "$result" =~ "dname" ]];then 
        while [[ "$result" =~ "dname" ]]
        do
            sleep 1
            str=${result##*"dname"}
            ancestors["$i"]=`echo $str  |awk -F ':' '{print $2}' | awk -F '"' '{print $2}'`
            ((i++))
            result=${result%"dirino"*}
        done

        for key in ${!ancestors[@]}
        do
            tmp_file=${tmp_file}"/"${ancestors[$key]}
        done

        file="$mount_point${tmp_file}"
        echo $file
    else 
	echo 1
    fi
}

function repaire_file()
{
    date >> $repaire_log		
    echo "will tail file: $1" >> $repaire_log
    #tail -n 1 $1
}


while true
do
    new_waitors=$(get_waitors)
    echo $new_waitors ${old_waitors} >> $repaire_log

    if [ ${new_waitors} -gt ${old_waitors} ];then
	ino=`cat $output_file |grep "waiting for caps" | tail -n 1 | awk -F ' ' '{print $14}' | awk -F '.' '{print $1}'`
	echo "will repaire $ino" >> $repaire_log
        ${py_cmd_path}/waiting_for_cap.py $ino  
	#bad_file=$(get_file)
	#if [ $bad_file != "1" ];then 
        #    repaire_file $bad_file
	#fi
    fi
    sleep 60 
    old_waitors=${new_waitors}
done
