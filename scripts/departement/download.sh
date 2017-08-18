#!/bin/bash

DEP=$(echo $1 | tr '[:lower:]' '[:upper:]' | sed "s/^/000/" | grep -o '...$')

if [[ "$DEP" == "000" ]]
then
	echo "Please provide a departement"
	exit 1
fi

echo "Download departement $DEP"

if [ ! -d workspace/$DEP/download/raw ]
then
	mkdir -p workspace/$DEP/download/raw
fi
if [ -d workspace/$DEP/download/data ]
then
	rm -r workspace/$DEP/download/data
fi
	
cd workspace/$DEP/download
curl -s "http://pro.ign.fr/bdortho-5m" | grep -o "https://wxs-tele[^\"]*" | grep BDORTHO | grep "D$DEP" > urls.txt
sed -i "s/https/http/g" urls.txt
cd raw
wget -N --progress=dot:mega $(cat ../urls.txt | tr '\n' ' ')
cd ..
cat $(ls -X raw/*.7z*) > data.7z
7z x data.7z
mkdir data
find . -name "*.jp2" | xargs -I FILE mv FILE ./data
rm *.7z.* *.7z
rm -r BDORTHO*