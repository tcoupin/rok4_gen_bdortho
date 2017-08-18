#!/bin/bash

DEP=$(echo $1 | tr '[:lower:]' '[:upper:]' | sed "s/^/000/" | grep -o '...$')

if [[ "$DEP" == "000" ]]
then
	echo "Please provide a departement"
	exit 1
fi

JOB_NUMBER=$(lscpu | grep "^CPU(s):" | awk '{print $2}')

docker run -v $PWD:$PWD -it --rm -d --name be4 -w $PWD/workspace/$DEP/be4_work tcoupin/rok4:be4 bash

for i in `seq 1 $JOB_NUMBER`
do
	docker exec -u $UID be4 bash scripts_be4/SCRIPT_${i}.sh &
done

wait

docker exec -u $UID be4 bash scripts_be4/SCRIPT_FINISHER.sh

docker exec -u $UID be4 create-layer.pl --pyr=pyramids/descriptors/BDORTHO-5M-${DEP}.pyr --tmsdir=./ --layerdir=pyramids/descriptors/

docker kill be4
sed -i "s#<pyramid.*#<pyramid>/rok4/config/pyramids/BDORTHO-5M-${DEP}/descriptors/BDORTHO-5M-${DEP}.pyr</pyramid>#g" $PWD/workspace/$DEP/be4_work/pyramids/descriptors/BDORTHO-5M-${DEP}.lay

###### ARCHIVE ######
mv $PWD/workspace/$DEP/be4_work/pyramids $PWD/workspace/$DEP/be4_work/BDORTHO-5M-${DEP}
cd $PWD/workspace/$DEP/be4_work/

tar -zcvf ../D$DEP-alone.tar.gz BDORTHO-5M-${DEP}
