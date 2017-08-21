#!/bin/bash

DEP=$(echo $1 | tr '[:lower:]' '[:upper:]' | sed "s/^/000/" | grep -o '...$')

if [[ "$DEP" == "000" ]]
then
	echo "Please provide a departement"
	exit 1
fi

if [ ! -d workspace/$DEP/download/raw ]
then
	mkdir -p workspace/$DEP/download/raw
fi
if [ -d workspace/$DEP/download/data ]
then
	rm -r workspace/$DEP/download/data
fi
	
cd workspace/$DEP/download
#curl -s "http://pro.ign.fr/bdortho-5m" | grep -o "https://wxs-tele[^\"]*" | grep BDORTHO | grep "D$DEP" > urls.txt
cat ../../../BDortho5M.list | grep BDORTHO | grep "D$DEP" > urls.txt
sed -i "s/https/http/g" urls.txt