#!/bin/bash

#!/bin/sh

if [ -z "$1"  ];then
    echo "no argument";
    exit 255
fi

depth_foler()
{
	this_dir=`pwd`
	source_folder="$1"
	source_folder=`echo $source_folder |sed 's#/$##g'`
	test_folder="$2"
	cd $test_folder
	count=0
	while [ ! `pwd` = $source_folder ]
	do
		count=`expr $count + 1`	
		cd ..
	done
	cd $this_dir
	return $count	
}

#echo $?
target_folder="$1"
depth_max=1
for i in `find "$target_folder" -type d` ;do
	if [ -d $i -a ! $i = $target_folder ];then
		depth_foler "$target_folder" "$i"
		retval=$?
		if [ $depth_max -lt $retval ];then
                        depth_max=$retval

                fi
#		echo "$i --depth: $retval"
	fi	
done
echo "max depth:$depth_max"
