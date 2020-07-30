#!/bin/bash

while getopts "t:n:p:r:c:a:f:" arg
do
    case $arg in
        t)
            mnt_type=$OPTARG
            echo "mount type is arg: $mnt_type"
            ;;
        n)
            mnt_node=$OPTARG
            echo "mount node is arg: $mnt_node"
            ;;
        p)
            mountpoint=$OPTARG
            echo "mountpoint is arg: $mountpoint"
            ;;
        r)
            test_type=$OPTARG
            echo "test type is arg: $test_type"
            ;;
        c)
            cluster_name=$OPTARG
	    echo "test cluster is arg: $cluster_name"
            ;;
        a)
            random_num=$OPTARG
            echo "test random_num is arg: $random_num"
            ;;
        f)
            conf_path=$OPTARG
            echo "test ceph config is arg: $conf_path "
            ;;
        \?)
            echo "unknow argument"
            ;;
    esac
done

trap 'umount -l $mountpoint' SIGINT SIGHUP SIGTERM SIGKILL SIGVTALRM SIGPROF SIGIO SIGPWR EXIT
wait $!

###########################################
# mount the mountpoint path
#
# mount_cephfs
###########################################
function mount_cephfs { 
    mkdir -p $mountpoint
    echo "start mount the path ${mountpoint} ..."
    
    # ceph config file exists or die
    if [ -f "${conf_path}/${cluster_name}.conf" ]
    then
        ceph-fuse $mountpoint -c ${conf_path}/${cluster_name}.conf --admin_socket /var/run/ceph/${cluster_name}-client.admin.${random_num}.asok --keyring ${conf_path}/${cluster_name}.client.admin.keyring --debug_client=2 --log-file /var/log/ceph/${cluster_name}-client.${random_num}.log

        if [ $? = 0 ]
        then
            echo "mountpoint is successful, ${mountpoint} ${cluster_name}"
        else
            echo "mountpoint is failed, ${mountpoint} ${cluster_name}"
            exit 1
        fi

    else
        echo "config error: lack of cluster config file"
        echo "mount failed"
        exit 1
    fi
}



###########################################
# is mounted or not
#
# is_mounted 
###########################################
function is_mounted {
    is_mount=`mountpoint ${mountpoint}|awk '{print $4}'`
    if [ "${is_mount}"x = "mountpoint"x ]
    then
        echo "${mountpoint} is mounted already!"
    else 
        echo "${mountpoint} is not mounted!"
        exit 1
    fi
}

###########################################
# print mount type server
#
# print_and_mount 
###########################################
function print_and_mount {
    if [ "$mnt_type"x = "nfs"x ]
    then
        echo "nfs" 
        mnt_option="-o vers=3,nolock"
        echo "$mnt_node  $mountpoint"
    elif [ "$mnt_type"x = "glusterfs"x ]
    then
        echo "glusterfs"
        echo "$mnt_node $mountpoint" 
    elif [ "$mnt_type"x = "cephfs"x ]
    then
        echo "cephfs"
        echo "mount ceph-fuse"
        mount_cephfs
        is_mounted
    else
        echo "unknow mount type"
        exit
    fi
}

###########################################
# prepare before test mountpoint
#
# test_pre 
###########################################
function test_pre {
    echo "prepare before test" 

    # switch the mountpoint path
    cd $mountpoint
   
    # create test path
    workDir="auto-test"
    # go to test dir
    if [ ! -d $workDir ];then
        mkdir -p $workDir
    fi
    
    cd $workDir
    
    test_args=${conf_path}/test_args.py
    test_conf=${conf_path}/test.conf
    if [ ! -f $test_args ]
    then
        cp /tests/test_args.py ${conf_path}
    fi
    if [ ! -f $test_conf ]
    then
        cp /tests/test.conf ${conf_path}
    fi
}

###########################################
# test mountpoint
#
# test_start 
###########################################
function test_start() {

    test_pre

    echo "start test ${test_type}"   

    python ${test_args} --run $test_type --mountpoint $mountpoint/$workDir/test_${test_type}_$(hostname -f)_$random_num --log $mountpoint/$workDir/test_${test_type}_$(hostname -f)_${random_num}.log ${test_conf}

}


test_all_cases=(vjtree iozone mdtest fsstress rsync pjd fio smallfile)
if [[ ${test_all_cases[@]} =~ ${test_type} ]]
then
    print_and_mount
    test_start
else
    echo "invalid test case type"
fi

cd /
umount -l ${mountpoint}
