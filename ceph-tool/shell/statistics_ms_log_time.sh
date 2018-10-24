#!/bin/bash 

# template
# client log
# 2018-10-23 18:01:18.151732 7fbeb730d700  1 -- 172.20.1.6:0/2414101458 --> 172.20.1.1:6800/14943 -- osd_op(client.1225369.0:2679 3.8402209d 1000004c016.00000704 [write 0~4194304] snapc 1=[] ondisk+write+known_if_redirected e408) v7 -- ?+0 0x7fbeca49d9c0 con 0x7fbeca411180
# server log
# 2018-10-23 18:01:18.364200 7faf5cfd0700  1 -- 172.20.1.1:6800/14943 <== client.1225369 172.20.1.6:0/2414101458 219 ==== osd_op(client.1225369.0:2679 3.8402209d (undecoded) ondisk+write+known_if_redirected e408) v7 ==== 206+0+4194304 (4232021976 0 0) 0x7fafb8dba2c0 con 0x7fafa2945080


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

    time_diff=$delta
    #time_diff=`awk 'BEGIN{printf "%.6f\n",('$delta'/'1000000')}'`
    #echo lat $time_diff 
	let total_op++
	total_time=$(echo "scale=6;$total_time+$time_diff"|bc)
	if [ $(echo "$time_diff > $max_time"|bc) ];then
		max_time=$time_diff
	fi
    echo $time_diff >> $OUTPUT_FILE
}


function cal_objecter_osd()
{
    grep -E "osd_op\(" $SRC_FILE > /tmp/.objecter_osd_op
    #cat /tmp/.mds_osd_op |grep ${OP_NAME} > /tmp/.objecter_osd_op_
    while read logstr
    do
        #echo $logstr
		pattern_str=`echo $logstr | awk -F ' ' '{print $10}'`
        t1_sec=`echo $logstr |awk -F ' ' '{print $2}' | awk -F '.' '{print $1}'`
        t1_sec=`date -d "$t1_sec" +%s`
		t1_msec=`echo $logstr | awk -F ' ' '{print $2}' | awk -F '.' '{print $2}'`
        #echo t1: $t1_sec $t1_msec
       
		dest_logstr=`grep -nr "${pattern_str}" $DEST_FILE`
        if [ -n "$dest_logstr" ];then
	    	t2_sec=`echo $dest_logstr |awk -F ' ' '{print $2}' | awk -F '.' '{print $1}'`
            t2_sec=`date -d "$t2_sec" +%s`
	    	t2_msec=`echo $dest_logstr |awk -F ' ' '{print $2}' | awk -F '.' '{print $2}'`
		    #echo t2: $t2_sec $t2_msec $t1_sec $t1_msec
            calculate_time_diff $t1_sec $t1_msec $t2_sec $t2_msec
        fi
        #echo $op_num
        #sleep 1
    done < /tmp/.objecter_osd_op
}

function print_result()
{   avg_time=$(echo "scale=7;${total_time}/${total_op}/1000000"|bc)
    total_time=$(echo "scale=7;${total_time}/1000000"|bc)
    max_time=$(echo "scale=7;${max_time}/1000000"|bc)
	echo "tolal_op: $total_op"
	echo "tolal_time: $total_time"
	echo "max_time: $max_time"
	echo "avg_time: $avg_time"
}
#main ...
if [ $# -lt 3 ]; then
    usage
    exit 0
fi

SRC_FILE=$1
DEST_FILE=$2
OUTPUT_FILE=$3
OP_NAME=$4

tolal_op=0
total_time=0
avg_time=0
max_time=0

echo src_file: $SRC_FILE
echo dest_file: $DEST_FILE
echo output_file: $OUTPUT_FILE
echo op_name: $OP_NAME 
echo "-----------------------------------"
rm -rf $OUTPUT_FILE

cal_objecter_osd     
print_result
