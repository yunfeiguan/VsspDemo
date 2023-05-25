#!/bin/sh

# Display drive bay for disks connected to SAS expander backplane

for name in /sys/block/* ; do
  npath=$(readlink -f $name)

  while [ $npath != "/" ] ; do
    npath=$(dirname $npath)
    ep=$(basename $npath)

    if [ -e $npath/sas_device/$ep/bay_identifier ] ; then
      bay=$(cat $npath/sas_device/$ep/bay_identifier)
      encl=$(cat $npath/sas_device/$ep/enclosure_identifier)

      echo "$name has BayID: $bay"

      break
    fi
  done

done

