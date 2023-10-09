#!/bin/sh

DATADIR=/data

case "$1" in
	backup)
		rsync -r --delete /etc/NetworkManager/system-connections $DATADIR/NetworkManager
		;;
	restore)
		rsync -r --delete $DATADIR/NetworkManager/system-connections /etc/NetworkManager
		;;
	*)
		echo "ERROR: unknown command"
		exit 1
		;;
esac
