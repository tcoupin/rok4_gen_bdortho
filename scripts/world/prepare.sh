#!/bin/bash


function norm () {
	echo $1 | tr '[:lower:]' '[:upper:]' | sed "s/^/000/" | grep -o '...$'
}

DEPS=$@


if [[ "$DEPS" == "" ]]
then
	echo "Please provide a list of departements, comma delimited"
	exit 1
fi

JOB_NUMBER=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
if [ -d workspace/world/be4_work ]
then
	rm -r workspace/world/be4_work
fi
mkdir -p workspace/world/be4_work
cp config/PM.tms workspace/world/be4_work
eval "echo \"$(cat config/join.txt.template)\"" > workspace/world/be4_work/prop.txt

echo $DEPS | tr ',' '\n' | while read DEP
do
	DEP=$(norm $DEP)
	BBOX=$(grep bounding workspace/$DEP/be4_work/BDORTHO-5M-$DEP/descriptors/BDORTHO-5M-$DEP.lay | awk -F '"' '{print $4","$6","$8","$10}')
	echo "D$DEP = $BBOX" >> workspace/world/be4_work/prop.txt
	echo "D$DEP = $BBOX" >> workspace/world/be4_work/pyramids/descriptors/bbox.txt
done

echo "[ composition ]" >> workspace/world/be4_work/prop.txt

echo $DEPS | tr ',' '\n' | while read DEP
do
	DEP=$(norm $DEP)
	for level in $(seq 0 15)
	do
		echo "$level.D$DEP = ../../$DEP/be4_work/BDORTHO-5M-$DEP/descriptors/BDORTHO-5M-$DEP.pyr" >> workspace/world/be4_work/prop.txt
	done
done

docker run -v $PWD:$PWD -u $UID --rm -w $PWD/workspace/world/be4_work tcoupin/rok4:be4 joinCache.pl --conf=prop.txt

# echo on command to avoid timeout on travis
sed -i "s/^\([a-zA-Z0-9]*\) () {/\1 () {\necho \"\1\: \$(date)\";/g" workspace/world/be4_work/scripts_be4/SCRIPT_*