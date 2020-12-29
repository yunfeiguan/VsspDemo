#!/bin/bash

#dir="/mnt/seven/test2"
dir=$1

#mkdir -p $dir

cd $dir

touch {1..3}

while true
do
   for i in `ls | grep -v yunfei`; do mv $i `expr ${i} + 10`;done
   for i in `ls | grep -v yunfei`; do mv $i `expr ${i} - 10`;done

   #rm -rf ${dir}/*
#touch {1..1000}
#sleep 1
done
