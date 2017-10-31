#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: "
    echo "sh set_log_level.sh mds.x 20"
    exit
fi

mds=$1
ceph daemon $mds config set debug_mds $2/$2 --cluster xtao 
ceph daemon $mds config set debug_journal $2/$2 --cluster xtao
ceph daemon $mds config set debug_mds_log $2/$2 --cluster xtao

