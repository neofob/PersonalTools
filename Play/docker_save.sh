#!/bin/bash
# __author__: tuan t. pham

# Description: a glorious shell script to save the typing of
# for i in `docker images | tail -n +2...;do docker save $i | xz ...>;done
# This script will save your docker image to a .tar.xz file

# To load the saved image:
# $ xzcat debian_jessie.tar.xz | docker load

# Define your own filter command to filter out the output of `docker images`
FILTER=${FILTER:="grep -v \"^None\""}
CPUS=${CPUS:=`grep -c processor /proc/cpuinfo`}

DEF_IMG="docker images | tail -n +2 | $FILTER | awk '{print \$1\":\"\$2}'"
IMG_CMD=${IMG:=$DEF_IMG}

OUTDIR=${OUTDIR:=.}

function set_compressor
{
	if [ "$COMPRESSOR" ]; then
		echo "Using user compressor $COMPRESSOR"
		echo $COMPRESSOR
		return
	fi

	which pxz >/dev/null
	if [ $? = 0 ]; then
		COMPRESSOR="pxz -T$CPUS -c9 - "
	else
		which xz >/dev/null
		if [ $? = 0 ]; then
			COMPRESSOR="xz -z -c9 "
		fi
	fi

	if [ ! "$COMPRESSOR" ]; then
		echo "Use default compressor gz"
		COMPRESSOR="gz -c"
	fi
}

function get_img
{
	IMG=`eval $IMG_CMD`
}

function main
{
	set_compressor
	echo "Compressor = $COMPRESSOR"
	get_img
	echo -e "Saving images:\n$IMG"

	for i in $IMG
	do
		echo -e "\nSaving docker image $i"
		OUTFILE=`echo $i | sed -e 's/\//_/g' | sed -e 's/:/_/'`
		CMD="docker save \$i | \$COMPRESSOR > \$OUTDIR/\$OUTFILE.tar.xz"
		echo $CMD
		eval $CMD
		#docker save $i | pxz -T$CPUS -c9 - > $OUTDIR/$OUTFILE.tar.xz
	done
}

main
