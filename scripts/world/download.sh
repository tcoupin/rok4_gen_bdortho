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

echo $DEPS | tr ',' '\n' | while read DEP
do
	DEP=$(norm $DEP)
	echo "Download departement $DEP"
	docker pull tcoupin/rok4-bdortho:$DEP-alone
	if [ ! -d workspace/$DEP/be4_work ]
	then
		mkdir -p workspace/$DEP/be4_work
	fi
	docker run --rm -u $UID -v $PWD/workspace/$DEP/be4_work:/be4_work tcoupin/rok4-bdortho:$DEP-alone cp -ur /rok4/config/pyramids/BDORTHO-5M-$DEP /be4_work/
done

