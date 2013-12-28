#!/bin/sh
size=$1
dir="$2"
suffix="$3"
scriptDir=$(cd `dirname $0` && pwd);
if [ -z "$size" ]; then
    size="-h"
fi
if [ "$size" == "-h" ]; then
    echo "usage: blip-all-svg2icons.sh size dir"
    echo "size=square pixel size of resulting png files"
    echo "dir=directory (default is current dir)"
fi
if [ -z "$dir" ]; then
    dir="."
fi
for file in "${dir}"/*.svg 
do 
   #echo $file
   "${scriptDir}/blip-svg2icon.sh" $size $file $suffix 
done