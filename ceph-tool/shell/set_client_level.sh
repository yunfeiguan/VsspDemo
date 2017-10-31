#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: "
    echo "sh set_log_level.sh mds.x 20"
    exit
fi

client=/var/run/ceph/xtao-client.${1}.asok


ceph --admin-daemon $client config set debug_monc $2/$2 --cluster xtao 
ceph --admin-daemon $client config set debug_client $2/$2 --cluster xtao 
ceph --admin-daemon $client config set debug_objecter $2/$2 --cluster xtao
ceph --admin-daemon $client config set debug_objectcacher $2/$2 --cluster xtao
ceph --admin-daemon $client config set debug_rados $2/$2 --cluster xtao
ceph --admin-daemon $client config set debug_striper $2/$2 --cluster xtao

