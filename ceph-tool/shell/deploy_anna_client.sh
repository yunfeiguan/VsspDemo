#!/bin/bash

if [ $# -lt 3 ]; then
    echo  "Usage: sh $0 raw_ip start end anna_images"
    exit
fi

raw_ip=$1
start=$2
end=$3
image=$4

for((i=$start; i<=$end; i++));do
    #ip_addr=${raw_ip}.$i
    ip_addr=${raw_ip}$i
    echo "will deploy ${ip_addr}"
    
    #copy docker image
    #scp /${image} root@${ip_addr}:/
    
    #copy xtanna mount.annafs 
    #scp /usr/bin/xtanna root@${ip_addr}:/usr/bin/
    #scp /usr/sbin/mount.annafs root@${ip_addr}:/usr/sbin/

    #copy xtao.conf keyring
    #ssh root@${ip_addr} mkdir -p /etc/annac/
    scp /etc/annac/xtao.conf root@${ip_addr}:/etc/annac/
    scp /etc/annac/xtao.client.admin.keyring root@${ip_addr}:/etc/annac/ 
    #scp /etc/ceph/xtao.client.admin.keyring root@${ip_addr}:/etc/ceph/ 

    #load anna client images
    #ssh ${ip_addr} docker load -i /${image} 
  
    #add route
    #ssh ${ip_addr} echo "ip route add 10.61.152.0/24 via 10.61.153.254" >> /etc/rc.local
    #ssh ${ip_addr} source /etc/rc.local
   
    #mount/remount fuse
    ssh root@${ip_addr} mkdir -p /mnt/read-fuse/
    #ssh ${ip_addr} umount -l /mnt/anna-fuse
    #ssh ${ip_addr} umount -l /mnt/registry
    #ssh ${ip_addr} xtanna destroy all 
    #ssh ${ip_addr} mkdir -p /mnt/registry
    #ssh ${ip_addr} systemctl reset-failed anna-fuse-136074.service
    #ssh ${ip_addr} mount -t annafs xtao /mnt/registry   
    #ssh ${ip_addr} mount -t annafs xtao /mnt/anna-fuse   
    ssh ${ip_addr} mount -t annac:annafs xtao /mnt/read-fuse   

    #chcek mount point 
    ssh ${ip_addr} df -lh |grep anna-fuse

    #restart all computer
    #ssh ${ip_addr} echo 1 > /proc/sys/kernel/sysrq 
    #ssh ${ip_addr} echo b > /proc/sysrq-trigger 

    #clean client
    #ssh ${ip_addr} xtanna destroy all 

    #delete anna-client images
    #ssh ${ip_addr} docker rmi anna-client 
 
done
