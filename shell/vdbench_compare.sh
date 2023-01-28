#!/bin/bash

dir_path=$1
threshold=$2
dir_array=()

if [ $# -lt 2 ];then
    echo "lack of args, dir and compared_value"
    exit 1
fi


function compare() {
  echo "----------------- start compare $1 -------------------"
  line=0
  my_dir=$1
  #generage statistics file
  cd $my_dir
  tail -n +30  summary.html | awk '{print $14}'  > statistics
  sed -i  '/^$/d' $my_dir/statistics
  sed -i  '/rmdir/d' $my_dir/statistics
  sed -i  '/rate/d' $my_dir/statistics
  #数值小于设置的threshold，而且字符串的长度要小于3
  for i in `cat $my_dir/statistics`; do ((line++)); ((kk=`echo $i | awk -F '.' '{print $1}'`)); if [[ $kk < $threshold || ${#kk} -lt 3 ]]; then echo $line-$i; fi; done
  echo "------------------- end compare ------------------------"
}

function main()
{
    dir_array=(`ls $dir_path`)
    #echo ${dir_array[0]}
    p_dir=$(pwd)

    for dir in ${dir_array[@]}; do
        com_dir=$p_dir/$dir
        echo $com_dir
        if [ -d $com_dir ]; then
            compare $com_dir
        fi
    done
}
main
