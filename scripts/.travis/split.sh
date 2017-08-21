#!/bin/bash

# ARGS
#	- SIZE_FILE (format: key size)
#	- NB_TASKS
#	- CURRENT_TASK
#	- SCRIPT

SIZE_FILE=$1
NB_TASKS=$2
CURRENT_TASK=$3
shift 3

cat $SIZE_FILE | sort -n -k 2 > ${SIZE_FILE}_sorted
mv ${SIZE_FILE}_sorted $SIZE_FILE

SUM=$(awk '{sum=sum+$2} END {print sum}' $SIZE_FILE)
DELTA=$(( SUM/$NB_TASKS+1 ))
BOTTOM=$(( $DELTA*($CURRENT_TASK-1) ))
TOP=$(( $DELTA*($CURRENT_TASK) ))


awk -v TOP=$TOP -v BOTTOM=$BOTTOM '{sum=sum+$2;if (sum > BOTTOM && sum <= TOP){print $1}}' $SIZE_FILE | while read DEP
do
	for script in $*
	do
		bash $script $DEP
	done
done

