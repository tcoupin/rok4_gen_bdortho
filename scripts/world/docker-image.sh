#!/bin/bash

cp docker/Dockerfile workspace/world/be4_work/

cd workspace/world/be4_work/
if [ -z "$TRAVIS_TAG" ]
then
	TAG=world
else
	TAG=$TRAVIS_TAG
fi
docker build -t tcoupin/rok4-bdortho:$TAG --build-arg FOLDER=BDORTHO-5M .
if [ ! -z "$DOCKER_USERNAME" ]
then
	docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
	docker push tcoupin/rok4-bdortho:$TAG
fi