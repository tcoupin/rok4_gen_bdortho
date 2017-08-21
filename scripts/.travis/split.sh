#!/bin/bash

# ARGS
#	- NB_TASKS
#	- CURRENT_TASK
#	- SCRIPT

NB_TASKS=$1
CURRENT_TASK=$2
shift 2

#compute "size" of each generation
for i in $(ls workspace)
do
	echo "$i $(cat workspace/$i/be4_work/scripts_be4/SCRIPT_*.sh | wc -l)" >> /tmp/tasks
done
cat /tmp/tasks | sort -n -k 2 > /tmp/tasks_sorted
mv /tmp/tasks_sorted /tmp/tasks

SUM=$(awk '{sum=sum+$2} END {print sum}' /tmp/tasks)
DELTA=$(( SUM/$NB_TASKS+1 ))
BOTTOM=$(( $DELTA*($CURRENT_TASK-1) ))
TOP=$(( $DELTA*($CURRENT_TASK) ))


awk -v TOP=$TOP -v BOTTOM=$BOTTOM '{sum=sum+$2;if (sum > BOTTOM && sum <= TOP){print $1}}' | while read DEP
do
	for script in $*
	bash $script $DEP
done

