#!/bin/bash

DEP=$(echo $1 | tr '[:lower:]' '[:upper:]' | sed "s/^/000/" | grep -o '...$')

if [[ "$DEP" == "000" ]]
then
	echo "Please provide a departement"
	exit 1
fi

URL=$(head -n 1 workspace/$DEP/download/urls.txt)
PRODUCT=$(echo $URL | grep -o '/[^/]*/file' | awk -F '/' '{print $2}')
FORMAT=$(echo $PRODUCT | grep -o -e TIFF -e JP2-E100)
PROJ=$(echo $PRODUCT | grep -o -e '_JP2-E100_[^_]*_'  -e '_TIFF_[^_]*_' | awk -F '_' '{print $3}')

echo "FORMAT = $FORMAT"
echo "PROJECTION = $PROJ"

JOB_NUMBER=$(lscpu | grep "^CPU(s):" | awk '{print $2}')


if [ -d workspace/$DEP/be4_work ]
then
	rm -r workspace/$DEP/be4_work
fi

mkdir -p workspace/$DEP/be4_work

cp config/env.txt workspace/$DEP/be4_work
eval "echo \"$(cat config/prop.txt.template)\"" > workspace/$DEP/be4_work/prop.txt
eval "echo \"$(cat config/sources.txt.template)\"" > workspace/$DEP/be4_work/sources.txt
cp config/PM.tms workspace/$DEP/be4_work

docker run -it -v $PWD:$PWD --rm -w $PWD/workspace/$DEP/be4_work tcoupin/rok4:be4 be4.pl --conf=prop.txt --env=env.txt

