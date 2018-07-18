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
    #ssh root@${ip_addr} rm -rf /anna-client*
    #scp /${image} root@${ip_addr}:/
    
    #copy xtanna mount.annafs 
    #scp /usr/bin/xtanna root@${ip_addr}:/usr/bin/
    #scp /usr/sbin/mount.annafs root@${ip_addr}:/usr/sbin/
    #scp /mount.annafs root@${ip_addr}:/usr/sbin/

    #copy xtao.conf keyring
    #ssh root@${ip_addr} mkdir -p /etc/annac/
    #scp /etc/annac/xtao.conf root@${ip_addr}:/etc/annac/
    #scp /etc/annac/xtao.client.admin.keyring root@${ip_addr}:/etc/annac/ 
    #scp /etc/ceph/xtao.client.admin.keyring root@${ip_addr}:/etc/ceph/ 

    #load anna client images
    #ssh ${ip_addr} docker rmi ${image} 
    #ssh ${ip_addr} docker load -i /${image} 
  
    #add route
    #ssh ${ip_addr} echo "ip route add 10.61.152.0/24 via 10.61.153.254" >> /etc/rc.local
    #ssh ${ip_addr} source /etc/rc.local
   
    #mount/remount fuse
    #ssh root@${ip_addr} mkdir -p /mnt/anna-fuse1/
    #ssh root@${ip_addr} mkdir -p /mnt/anna-fuse2/
    #ssh root@${ip_addr} mkdir -p /mnt/anna-fuse3/
    #ssh root@${ip_addr} mkdir -p /mnt/anna-fuse4/
    #ssh root@${ip_addr} mkdir -p /mnt/anna-fuse5/
    #ssh ${ip_addr} umount -l /mnt/anna-fuse
    #ssh ${ip_addr} umount -l /mnt/registry
    #ssh ${ip_addr} xtanna destroy all 
    #ssh ${ip_addr} xtanna destroy anna-fuse-136074 
    #ssh ${ip_addr} mkdir -p /mnt/registry
    #ssh ${ip_addr} systemctl reset-failed anna-fuse-136074.service
    #ssh ${ip_addr} mount -t annafs xtao /mnt/registry   
    #ssh ${ip_addr} mount -t annafs xtao /mnt/anna-fuse   
    #ssh ${ip_addr} mount -t annafs annac:xtao /mnt/anna-fuse1   
    #ssh ${ip_addr} mount -t annafs annac:xtao /mnt/anna-fuse2   
    #ssh ${ip_addr} mount -t annafs annac:xtao /mnt/anna-fuse3   
    #ssh ${ip_addr} mount -t annafs annac:xtao /mnt/anna-fuse4   
    #ssh ${ip_addr} mount -t annafs annac:xtao /mnt/anna-fuse5   
    #ssh ${ip_addr} mount -t annafs annac:xtao /mnt/anna-fuse   
    #ssh ${ip_addr} umount -l /mnt/anna-fuse1   
    #ssh ${ip_addr} umount -l /mnt/anna-fuse2   
    #ssh ${ip_addr} umount -l /mnt/anna-fuse3   
    #ssh ${ip_addr} umount -l /mnt/anna-fuse4   
    #ssh ${ip_addr} umount -l /mnt/anna-fuse5   

    #chcek mount point 
    #ssh ${ip_addr} mountpoint /mnt/anna-fuse
    #ssh ${ip_addr} docker ps |grep anna-fuse

    #restart all computer
    #ssh ${ip_addr} echo 1 > /proc/sys/kernel/sysrq 
    #ssh ${ip_addr} echo b > /proc/sysrq-trigger 

    #clean client
    #ssh ${ip_addr} xtanna destroy all 

    #delete anna-client images
    #ssh ${ip_addr} docker rmi anna-client-yunfei 
 
    #fio test tools
    #rpm -ivh /$anna_images	
    #scp /fio_read.sh root@${ip_addr}:/
    #ssh ${ip_addr} pkill -9 fio
    
    #clear cores 
    #ssh ${ip_addr} rm -rf /var/crash/ceph-fuse*

    #iozone test tools
    #ssh ${ip_addr} pkill -9 iozone
    #scp /fio_read.sh root@${ip_addr}:/
    #scp /iozone.sh root@${ip_addr}:/
    #scp /iozone_multi2.sh root@${ip_addr}:/
    #scp /usr/bin/iozone root@${ip_addr}:/usr/bin/
    #create log dir
    #ssh ${ip_addr} mkdir -p /home/log/iozone_test/
    #scp /usr/sbin/mount.annafs root@${ip_addr}:/usr/sbin/
   
    #set client log
    ssh ${ip_addr} ceph --admin-daemon /var/run/ceph/xtao-client.admin.136074.asok config set debug_client 5
done
