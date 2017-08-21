#!/bin/bash

function norm () {
	echo $1 | tr '[:lower:]' '[:upper:]' | sed "s/^/000/" | grep -o '...$'
}

DEPS=$@


if [[ "$DEPS" == "" ]]
then
	echo "Please provide a list of departements, comma delimited"
	exit 1
fi

if [ ! -d workspace ]
then
	mkdir workspace
fi

bash $(dirname $0)/batch.sh scripts/departement/download/urls.sh $DEPS
bash $(dirname $0)/batch.sh scripts/departement/download/size.sh $DEPS > workspace/sizes