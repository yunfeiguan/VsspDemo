#!/bin/bash 

op=$1
if [ $op = "reset" ];then
    ceph --admin-daemon /var/run/ceph/xtao-mds.xt1.asok perf reset objecter  --cluster xtao    
    ceph --admin-daemon /var/run/ceph/xtao-osd.0.asok perf reset leveldb  --cluster xtao    
    exit
fi
while true
do
    ceph --admin-daemon /var/run/ceph/xtao-mds.xt1.asok perf dump  --cluster xtao |grep omap
    ceph --admin-daemon /var/run/ceph/xtao-osd.0.asok perf dump leveldb --cluster xtao 
    sleep 2 
done
