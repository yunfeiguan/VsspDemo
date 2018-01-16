#!/bin/bash 

#if [ $# -lt 0 ];then
#    echo "Usage: sh $0 log_path"
#    exit 1
#fi
#MOUNT_POINT="/mnt/anna-fuse/test_fio"
MOUNT_POINT="/mnt/anna-fuse/fio_test"
LOG_PATH="/home/log/fio_test"

THREAD=4
BS=4k
SIZE=64G
RUNTIME=3600
RW=randwrite

for i in `seq 1 2`
do 
{
	#fio -filename=${MOUNT_POINT}/$(hostname -f)_$i -direct=1 -iodepth 1 -thread -rw=read -ioengine=libaio -bs=128k -size=128G -numjobs=16 -runtime=2000 -group_reporting -name=mytest_$(hostname -f)_$i 2>&1 | tee -a ${LOG_PATH}/test_${i}.log 
    echo > ${LOG_PATH}/test_$(hostname -f)_$i.log
    fio --name=4kwrite_iops_$(hostname -f)_$i --filename=${MOUNT_POINT}/$(hostname -f)_$i --numjobs=4 --bs=$BS --size=$SIZE --ioengine=libaio --direct=1 --randrepeat=0 --norandommap --rw=$RW --group_reporting --iodepth=512 --iodepth_batch=128 --iodepth_batch_complete=128 --gtod_reduce=1 --runtime=$RUNTIME 2>&1 | tee -a ${LOG_PATH}/test_$(hostname -f)_${i}.log &
}
done
#&
#done && wait
