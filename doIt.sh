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
	curl -s "http://pro.ign.fr/bdortho-5m" | grep -o "https://wxs-tele[^\"]*" | grep BDORTHO | grep "D$DEP" > ../urls.txt
	sed -i "s/https/http/g" ../urls.txt
	wget --progress=dot:mega $(cat ../urls.txt | tr '\n' ' ')
	cat $(ls -X *) > data.7z
    7z x data.7z
    mkdir data
    find . -name "*.jp2" | xargs -I FILE mv FILE ./data
    rm *.7z.*
    rm -r BDORTHO*
fi

###### METADATA ######
cd $WORK_DIR
URL=$(head -n 1 urls.txt)
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
docker run -v $WORK_DIR:/DATA -it --rm -d --name be4 tcoupin/rok4:be4 bash
docker exec -u 1000 be4 be4.pl --conf=/DATA/be4_work/prop.txt --env=/DATA/be4_work/env.txt

for i in `seq 1 $JOB_NUMBER`
do
	docker exec -u 1000 be4 bash /DATA/be4_work/scripts_be4/SCRIPT_${i}.sh &
done

wait

docker exec -u 1000 be4 bash /DATA/be4_work/scripts_be4/SCRIPT_FINISHER.sh

docker exec -u 1000 be4 create-layer.pl --pyr=/DATA/be4_work/pyramids/descriptors/BDORTHO-5M-${DEP}.pyr --tmsdir=/DATA/be4_work --layerdir=/DATA/be4_work/pyramids/descriptors/

docker kill be4
sed -i "s#<pyramid.*#<pyramid>/rok4/config/pyramids/descriptors/BDORTHO-5M-${DEP}.pyr</pyramid>#g" pyramids/descriptors/BDORTHO-5M-${DEP}.lay

###### ARCHIVE ######
cd $WORK_DIR/be4_work/pyramids

tar -zcvf ../../D$DEP-alone.tar.gz *