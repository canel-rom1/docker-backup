#!/bin/sh

set -e
trap "echo SIGNAL" HUP INT QUIT KILL TERM

if [ "$1" = "backup" ] ; then
        [ -n "${2}" ] && shift
	exec /usr/local/bin/dkbk backup "$@"
fi

exec "$@"
