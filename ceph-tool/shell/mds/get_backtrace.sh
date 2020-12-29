#!/usr/bin/env bash

file=$1
ino=`stat -c %i ${file}`
tmep_file="/tmp/.parent"
declare -A map=（）
declare -A ancestors=（）

function dec2hex()
{
    printf "%0x" $1
}

function get_backtrace()
{
    rados -p cephfs_data getxattr ${1}.00000000 parent --cluster xtao > /tmp/.parent
    ceph-dencoder import /tmp/.parent type inode_backtrace_t decode dump_json
}

ino_hex=$(dec2hex $ino)

#ino_hex=$1

result=$(get_backtrace $ino_hex)

i=0
while [[ "$result" =~ "dname" ]]
do
    sleep 1
    str=${result##*"dname"}
    ancestors["$i"]=`echo $str  |awk -F ':' '{print $2}' | awk -F '"' '{print $2}'`
    ((i++))
    result=${result%"dirino"*}
done

tmp_file=""
for key in ${!ancestors[@]}
do
    tmp_file=${tmp_file}"/"${ancestors[$key]}
done

file="/mnt/seven${tmp_file}"
echo $file
