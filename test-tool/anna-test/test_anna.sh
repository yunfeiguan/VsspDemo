#!/bin/bash

TEST_TYPE=(vjtree iozone rsync fsstress mdtest pjd fio smallfile) 
MOUNTPOINT=/mnt/test-anna
CLUSTER=xtao
DOCKER_IMAGE=anna-test

DOCKER_START="-v /entrypoint -v /etc/ceph:/etc/ceph  --cap-add SYS_ADMIN --device /dev/fuse -v /var/run/ceph:/var/run/ceph -v /var/crash:/var/crush -v /var/log/ceph:/var/log/ceph --hostname $(hostname -f) $DOCKER_IMAGE --net=host --privileged"

DOCKER_PRE="docker run"
DOCKER_SUF="-c $CLUSTER -t cephfs "

TEST_LOG=/home/test/log

count=1
test_loop=3

if [ ! -d $MOUNTPOINT ]
then
    mkdir -p $MOUNTPOINT
fi

if [ ! -d $TEST_LOG ]
then
    mkdir -p $TEST_LOG
else
    rm -rf ${TEST_LOG}/anna_test.log
fi

while [ $count -le $test_loop ]
do
{
    echo " the loop is $count"|tee -a $TEST_LOG/anna_test.log
    echo $(date +%Y-%m-%d) $(date +%H:%M:%S) "Start anna test loop $count" |tee -a $TEST_LOG/anna_test.log
    start_seconds=$(date +%s)
    random_num=$RANDOM

    for test_type in ${TEST_TYPE[*]}
    do
    {
        start_test=$(date +%s)
        echo $(date +%Y-%m-%d) $(date +%H:%M:%S) "Start anna test loop $count ${test_type}" |tee -a $TEST_LOG/anna_test.log
        echo "$DOCKER_PRE --name test-${test_type}-${random_num} -v ${MOUNTPOINT}/test-${test_type}-${random_num}:${MOUNTPOINT}/test-${test_type}-${random_num}:shared $DOCKER_START $DOCKER_SUF -r $test_type -p ${MOUNTPOINT}/test-${test_type}-${random_num} -a ${random_num}"|tee -a $TEST_LOG/anna_test.log
        $DOCKER_PRE --name test-${test_type}-${random_num} -v ${MOUNTPOINT}/test-${test_type}-${random_num}:${MOUNTPOINT}/test-${test_type}-${random_num}:shared $DOCKER_START $DOCKER_SUF -r $test_type -p ${MOUNTPOINT}/test-${test_type}-${random_num} -a ${random_num}
        end_test=$(date +%s)
        test_duration=$(( end_test - start_test ))
        echo $(date +%Y-%m-%d) $(date +%H:%M:%S) "End anna test loop $count ${test_type}" |tee -a $TEST_LOG/anna_test.log
        echo "perform anna test loop $count ${test_type} case of time: " ${test_duration} "s" |tee -a $TEST_LOG/anna_test.log
    }
    done

    end_seconds=$(date +%s)
    duration=$(( end_seconds - start_seconds ))
    echo $(date +%Y-%m-%d) $(date +%H:%M:%S) "End anna test loop $count" |tee -a $TEST_LOG/anna_test.log  
    echo "perform anna test loop $count case of time: " $duration "s" |tee -a $TEST_LOG/anna_test.log

    echo "waiting the loop $count to drop the containers" |tee -a $TEST_LOG/anna_test.log
    for test_type in ${TEST_TYPE[*]}
    do
        docker rm -f test-${test_type}-${random_num}
        echo "docker rm -f test-${test_type}-${random_num}" |tee -a $TEST_LOG/anna_test.log
    done

    count=$(($count+1))

}
done
