#!/bin/bash

# ARGS
#	- NB_TASKS
#	- CURRENT_TASK
#	- SCRIPT

NB_TASKS=$1
CURRENT_TASK=$2
shift 2

TMP_FILE=$(mktemp)
#compute "size" of each generation
for i in $(ls workspace)
do
	echo "$i $(cat workspace/$i/be4_work/scripts_be4/SCRIPT_*.sh | wc -l)" >> $TMP_FILE
done
cat $TMP_FILE | sort -n -k 2 > ${TMP_FILE}_sorted
mv ${TMP_FILE}_sorted $TMP_FILE

SUM=$(awk '{sum=sum+$2} END {print sum}' $TMP_FILE)
DELTA=$(( SUM/$NB_TASKS+1 ))
BOTTOM=$(( $DELTA*($CURRENT_TASK-1) ))
TOP=$(( $DELTA*($CURRENT_TASK) ))


awk -v TOP=$TOP -v BOTTOM=$BOTTOM '{sum=sum+$2;if (sum > BOTTOM && sum <= TOP){print $1}}' $TMP_FILE | while read DEP
do
	for script in $*
	do
		bash $script $DEP
	done
done

