#!/bin/bash

user_name=$1
user_path=$1

#create auth
ceph auth get-or-create client.${user_name} mon 'allow r' mds 'allow rw path=/'$user_path'' osd 'allow rw pool=cephfs_metadata, allow rw pool=cephfs_data' --cluster xtao
ceph auth get client.${user_name} --cluster xtao > /etc/ceph/xtao.client.${user_name}.keyring

#create dir
rmdir -f /mnt/${user_path}
mkdir /mnt/${user_path}

#mount dir
ceph-fuse -n client.${user_name} --cluster xtao /mnt/${user_path} -r /${user_path}
