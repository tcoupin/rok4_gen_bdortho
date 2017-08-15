#!/bin/bash

DEP=$(echo $DEP | tr '[:lower:]' '[:upper:]' | sed "s/^/000/" | grep -o '...$')

if [[ "$DEP" == "000" ]]
then
	echo "Please set DEP env var"
	exit 1
fi


WORK_DIR=$PWD
###### DOWNLOAD ######
if [ ! -d download ]
then
	echo "Download departement $DEP"
	mkdir download
	cd download
	curl -s "http://pro.ign.fr/bdortho-5m" | grep -o "https://wxs-tele[^\"]*" | grep BDORTHO | grep "D$DEP" > urls.txt
	wget $(cat urls.txt | tr '\n' ' ')
	cat $(ls -X *.7z) > data.7z
        7zr x data.7z
        mkdir data
        find . -name "*.jp2" | xargs -I FILE mv FILE ./data
        rm *.7z
        rm -r BDORTHO*
fi

###### METADATA ######
cd $WORK_DIR
URL=$(head -n 1 download/urls.txt)
PRODUCT=$(echo $URL | grep -o '/[^/]*/file' | awk -F '/' '{print $2}')
FORMAT=$(echo $PRODUCT | grep -o -e TIFF -e JP2-E100)
PROJ=$(echo $PRODUCT | grep -o -e '_JP2-E100_[^_]*_'  -e '_TIFF_[^_]*_' | awk -F '_' '{print $3}')

echo "FORMAT = $FORMAT"
echo "PROJECTION = $PROJ"

JOB_NUMBER=$(lscpu | grep "^CPU(s):" | awk '{print $2}')

###### PREPARE ######
if [ -d be4_work ]
then
	rm -r be4_work
fi
mkdir be4_work
cd be4_work
cp ../config/env.txt .
eval "echo \"$(cat ../config/prop.txt.template)\"" > prop.txt
eval "echo \"$(cat ../config/sources.txt.template)\"" > sources.txt
cp ../PM.tms .


###### GENERATE ######
be4.pl --conf=prop.txt --env=env.txt

for i in `seq 1 $JOB_NUMBER`
do
	bash scripts_be4/SCRIPT_${i}.sh &
done

wait

bash scripts_be4/SCRIPT_FINISHER.sh

create-layer.pl --pyr=pyramids/descriptors/BDORTHO-5M.pyr --tmsdir=./ --layerdir=pyramids/descriptors/

sed -i "s#<pyramid.*#<pyramid>/rok4/config/pyramids/descriptors/BDORTHO-5M.pyr</pyramid>#g" pyramids/descriptors/BDORTHO-5M.lay

###### ARCHIVE ######
cd $WORK_DIR/be4_work/pyramids

tar -zcvf ../../D$DEP-alone.tar.gz *