#!/bin/bash

DEP=$(echo $1 | tr '[:lower:]' '[:upper:]' | sed "s/^/000/" | grep -o '...$')

if [[ "$DEP" == "000" ]]
then
	echo "Please provide a departement"
	exit 1
fi
	
cd workspace/$DEP/download
size=0
for url in $(cat urls.txt)
do
	cur_size=$(curl -s -I $url | grep Content-Length | awk -F ':' '{print $2}' | grep -o '[0-9]*')
	size=$(( $size+$cur_size ))
done

echo $DEP $size

