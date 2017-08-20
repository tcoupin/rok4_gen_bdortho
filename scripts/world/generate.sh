#!/bin/bash

JOB_NUMBER=$(lscpu | grep "^CPU(s):" | awk '{print $2}')

docker run -v $PWD:$PWD -it --rm -d --name be4 -w $PWD/workspace/world/be4_work tcoupin/rok4:be4 bash

for i in `seq 1 $JOB_NUMBER`
do
	docker exec -u $UID be4 bash scripts_be4/SCRIPT_${i}.sh &
done

wait

docker exec -u $UID be4 create-layer.pl --pyr=pyramids/descriptors/BDORTHO-5M.pyr --tmsdir=./ --layerdir=pyramids/descriptors/

docker kill be4
sed -i "s#<pyramid.*#<pyramid>/rok4/config/pyramids/BDORTHO-5M/descriptors/BDORTHO-5M.pyr</pyramid>#g" $PWD/workspace/world/be4_work/pyramids/descriptors/BDORTHO-5M.lay

###### ARCHIVE ######
mv $PWD/workspace/world/be4_work/pyramids $PWD/workspace/world/be4_work/BDORTHO-5M
cd $PWD/workspace/world/be4_work/

tar -zcvhf ../world.tar.gz BDORTHO-5M
