#!/bin/bash 


function usage () {
        cat <<EOF

Usage: $0 <type> <log_file> <output_file> [op_name]
  <type>:
      osd: statiscs time from osd_op to osd_reply
      fetch: statiscs mds fetch omap time    
 
EOF
        exit 1
}

function calculate_time_diff()
{
    time1_sec=$1
    time1_msec=$2

    time2_sec=$3
    time2_msec=$4

    delta=$(( (10#${time2_sec}*1000000 + 10#${time2_msec}) - (10#${time1_sec}*1000000 + 10#${time1_msec}) ))

    time_diff=`awk 'BEGIN{printf "%.6f\n",('$delta'/'1000000')}'`
    #echo lat $time_diff 
    echo $time_diff >> $OUTPUT_FILE
}


function cal_mds_osd()
{
    grep -E "osd_op|osd_op_replay" $SAMPLE_FILE > /tmp/.mds_osd_op
    cat /tmp/.mds_osd_op |grep ${OP_NAME} > /tmp/.mds_osd_op_
    op_num=1
    while read logstr
    do
        #echo $logstr
        if test `expr $op_num % 2` != 0;then
            t1_sec=`echo $logstr |awk -F ' ' '{print $2}' |awk -F ':' '{print $3}' | awk -F '.' '{print $1}'`
            t1_msec=`echo $logstr |awk -F ' ' '{print $2}' |awk -F ':' '{print $3}' | awk -F '.' '{print $2}'`
            #echo t1: $t1_sec $t1_msec
        else
            t2_sec=`echo $logstr |awk -F ' ' '{print $2}' |awk -F ':' '{print $3}' | awk -F '.' '{print $1}'`
            t2_msec=`echo $logstr |awk -F ' ' '{print $2}' |awk -F ':' '{print $3}' | awk -F '.' '{print $2}'`
  	    #echo "ou shu" 
            #echo t2: $t2_sec $t2_msec $t1_sec $t1_msec
            calculate_time_diff $t1_sec $t1_msec $t2_sec $t2_msec
        
        fi
        ((op_num=op_num+1));
        #echo $op_num
        #sleep 1
    done < /tmp/.mds_osd_op_
    num=$((op_num=op_num/2))
    echo have $num operations
}


function cal_mds_omap_fetch()
{
    grep -E "fetch on | _fetched header" $SAMPLE_FILE > /tmp/.mds_omap_fetch 
    op_num=1
    while read logstr
    do
        #echo $logstr
        if test `expr $op_num % 2` != 0;then
            t1_sec=`echo $logstr |awk -F ' ' '{print $2}' |awk -F ':' '{print $3}' | awk -F '.' '{print $1}'`
            t1_msec=`echo $logstr |awk -F ' ' '{print $2}' |awk -F ':' '{print $3}' | awk -F '.' '{print $2}'`
            #echo t1: $t1_sec $t1_msec
        else
            t2_sec=`echo $logstr |awk -F ' ' '{print $2}' |awk -F ':' '{print $3}' | awk -F '.' '{print $1}'`
            t2_msec=`echo $logstr |awk -F ' ' '{print $2}' |awk -F ':' '{print $3}' | awk -F '.' '{print $2}'`
            #echo "ou shu" 
            #echo t2: $t2_sec $t2_msec $t1_sec $t1_msec
            calculate_time_diff $t1_sec $t1_msec $t2_sec $t2_msec
            
        fi  
        ((op_num=op_num+1));
        #echo $op_num
        #sleep 1
    done < /tmp/.mds_omap_fetch
    num=$((op_num=op_num/2))
    echo have $num operations
}

#main ...
if [ $# -lt 3 ]; then
    usage
    exit 0
fi

OP_TYPE=$1
SAMPLE_FILE=$2
OUTPUT_FILE=$3
OP_NAME=$4

echo log_file: $SAMPLE_FILE
echo output_file: $OUTPUT_FILE
echo op_name: $OP_NAME 

rm -rf $OUITPUT_FILE

if [ $OP_TYPE == "osd" ];then
    cal_mds_osd     
elif [ $OP_TYPE == "fetch" ];then
    cal_mds_omap_fetch
fi 
