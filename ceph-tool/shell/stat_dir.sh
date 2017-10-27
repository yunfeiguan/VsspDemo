#!/bin/bash 

file=$1
ino=`stat -c %i ${file}`

function dec2hex()
{
	printf "%0x" $1
}

ino_hex=$(dec2hex $ino)

oid="${ino_hex}.00000000"

echo $oid

#get omapheader 
rados -p cephfs_metadata getomapheader $oid /tmp/kkkkk --cluster xtao
ceph-dencoder import /tmp/kkkkk type fnode_t  decode dump_json 

rm -rf /tmp/kkkkk
