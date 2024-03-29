#/bin/bash
#mount_uuid=$1
IMAGE_NAME="ceph-n-jwd_mempool"
#list=`docker ps -a |grep xtao-osd | awk -F ' ' '{print $10}' | awk -F '.' '{print $2}'`
list=`ls /var/lib/ceph/osd/ | awk -F '-' '{print $2}'`

for i in ${list[@]} 
do
  osd_num=$i

#acquire mount uuid
  mount_uuid=`docker inspect xtao-osd.${osd_num} |grep mnt |grep Source | awk -F ':' '{print $2}' | awk -F '/' '{print $3}' | awk -F '"' '{print $1}'`

#delete old osd container
  systemctl stop xtao-osd.${osd_num}
  docker rm -f xtao-osd.${osd_num}

# create new osd container
  echo "docker create --net=host --pid=host -v /mnt/${mount_uuid}:/mnt/${mount_uuid}:shared -v /var/lib/ceph/osd:/var/lib/ceph/osd:shared -v /var/crash:/var/crash:shared -v /var/run/ceph:/var/run/ceph:shared -v /var/log/ceph:/var/log/ceph:shared -v /etc/ceph:/etc/ceph -v /dev:/dev:shared -v /entrypoint --privileged -e CLUSTER=xtao -e OSD_ID=${osd_num}  --name=xtao-osd.${osd_num} ceph osd"

  docker create --net=host --pid=host -v /mnt/${mount_uuid}:/mnt/${mount_uuid}:shared -v /var/lib/ceph/osd:/var/lib/ceph/osd:shared -v /var/crash:/var/crash:shared -v /var/run/ceph:/var/run/ceph:shared -v /var/log/ceph:/var/log/ceph:shared -v /etc/ceph:/etc/ceph -v /dev:/dev:shared -v /entrypoint --privileged -e CLUSTER=xtao -e OSD_ID=${osd_num}  --name=xtao-osd.${osd_num} ${IMAGE_NAME} osd

# start new osd container
  systemctl reset-failed xtao-osd.${osd_num}.service
  systemctl start xtao-osd.${osd_num}.service
done
