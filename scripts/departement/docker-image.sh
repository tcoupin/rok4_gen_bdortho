#!/bin/bash

DEP=$(echo $1 | tr '[:lower:]' '[:upper:]' | sed "s/^/000/" | grep -o '...$')

if [[ "$DEP" == "000" ]]
then
	echo "Please provide a departement"
	exit 1
fi

cp docker/Dockerfile workspace/$DEP/be4_work/

cd workspace/$DEP/be4_work/

docker build -t tcoupin/rok4-bdortho:$DEP-alone --build-arg FOLDER=BDORTHO-5M-${DEP} .
if [ ! -z "$DOCKER_USERNAME" ]
then
	docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
	docker push tcoupin/rok4-bdortho:$DEP-alone
fi