#!/bin/bash

function norm () {
	tr '[:lower:]' '[:upper:]' | sed "s/^/000/" | grep -o '...$'
}

SCRIPT=$1

shift

DEPS=$@


if [[ "$DEPS" == "" ]]
then
	echo "Please provide a list of departements, comma delimited"
	exit 1
fi

echo $DEPS | tr ',' '\n' | norm | xargs -n 1 -P 10 bash $SCRIPT