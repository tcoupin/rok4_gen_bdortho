#!/bin/bash

DEP=$(echo $1 | tr '[:lower:]' '[:upper:]' | sed "s/^/000/" | grep -o '...$')

if [[ "$DEP" == "000" ]]
then
	echo "Please provide a departement"
	exit 1
fi

echo "Download departement $DEP"

bash $(dirname $0)/download/urls.sh $DEP


cd workspace/$DEP/download/raw
wget -N --progress=dot:mega $(cat ../urls.txt | tr '\n' ' ')
cd ..
cat $(ls -X raw/*.7z*) > data.7z
7z x data.7z
mkdir data
find . -name "*.jp2" | xargs -I FILE mv FILE ./data
rm *.7z.* *.7z
rm -r BDORTHO*