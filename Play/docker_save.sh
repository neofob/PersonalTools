#!/bin/bash
# __author__: tuan t. pham

# Description: a glorious shell script to save the typing of
# for i in `docker images | tail -n +2...;do docker save $i | xz ...>;done
# This script will save your docker image to a .tar.xz file

# To load the saved image:
# $ xzcat debian_jessie.tar.xz | docker load

# Define your own filter command to filter out the output of `docker images`
FILTER=${FILTER:="grep -vi \"^<None>\""}
CPUS=${CPUS:=`grep -c processor /proc/cpuinfo`}

DEF_IMG_CMD="docker images | tail -n +2 | $FILTER | awk '{print \$1\":\"\$2}'"
IMG_CMD=${IMG_CMD:=$DEF_IMG_CMD}

OUTDIR=${OUTDIR:=.}

function set_compressor
{
	if [ "$COMPRESSOR" ]; then
		echo "Using user compressor command '$COMPRESSOR'"
		echo "Filename extension = .$COMP_EXT"
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
		COMP_EXT="gz"
	else
		COMP_EXT="xz"
	fi
}

function get_img
{
	if [ ! "$IMG" ]; then
		IMG=`eval $IMG_CMD`
	fi
}

function main
{
	set_compressor
	echo "Compressor Command = '$COMPRESSOR'"
	get_img
	echo -e "Saving image(s):\n$IMG"

	for i in $IMG
	do
		echo -e "\nSaving docker image '$i'"
		OUTFILE=`echo $i | sed -e 's/\//_/g' | sed -e 's/:/_/'`
		CMD="docker save \$i | \$COMPRESSOR > \$OUTDIR/\$OUTFILE.tar.$COMP_EXT"
		echo "Output file = '$OUTDIR/$OUTFILE.tar.$COMP_EXT'"
		# echo $CMD
		eval $CMD
	done
}

main
