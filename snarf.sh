#! /bin/bash

# script to make symbolic links to a bunch of cozy grove source images

SRC=${1-.}
DST=${2-.}

TYPS="jpg png PNG"

for T in $TYPS; do

    IFS=$'\n' read -a my_array -d '' <<< `find $SRC -name *.$T -print`

    for i in "${my_array[@]}"; do
	echo $i
	IFS='/' read -ra arr <<< "$i"
	fn=`echo "${arr[-1]}" | sed 's/[() ]/-/g'`
	ln -s "$i" "$fn"
    done
done

