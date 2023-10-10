#!/bin/sh

# set -x

DATADIR=/data
DATAPART=3

# configure data partition with 512M size at 14G offset
SFDISK_INPUT="start=14G, size=512M, name=data"

# sfdisk creates $BACKUP-$PKNAME-<offset>.bak files
SFDISK_BACKUP=/tmp/sfdisk

# acquire partition and block device for the root mount point
eval $(/usr/bin/lsblk -PoPKNAME,MOUNTPOINT | /usr/bin/grep 'MOUNTPOINT="/"')

DATADEV=/dev/${PKNAME}p${DATAPART}

note() {
	echo "NOTE: $@"
}

die() {
	echo "ERROR: $@"
	exit 1
}

# expect that the rootfs is mounted to mmcblkXp2
[ -n "${PKNAME#mmcblk}" ] || die "skip mounting since the rootfs is not on EMMC/SD card."

# check if the data partition is present
if [ ! -b "$DATADEV" ]; then
	# add data partition
	if ! echo $SFDISK_INPUT | /usr/sbin/sfdisk -f -b -O $SFDISK_BACKUP -a /dev/$PKNAME; then
		backups=$(ls $SFDISK_BACKUP-$PKNAME*)
		# restore raw data
		for f in $backups; do
			off=${f%.bak}
			off=${off##*-}
			off=$(printf %d $off)
			dd if=$f of=/dev/$PKNAME seek=$off bs=1 conv=notrunc status=none
			rm -rf $f
		done
		# re-scan partitions
		partprobe /dev/$PKNAME
		die "failed to create data partition"
	fi

	# re-scan partitions
	partprobe /dev/$PKNAME
fi

# quietly check if the filesystem is okay
if ! fsck.ext4 -n $DATADEV 2>/dev/null >/dev/null; then
	note "creating ext4 filesystem on the data partition"
	mkfs.ext4 $DATADEV > /dev/null || die "failed to create filesystem"
fi

# mount data partition
mkdir -p $DATADIR && mount $DATADEV $DATADIR || die "failed to mount data partition"

# backup persistent data if needed
if [ ! -f $DATADIR/backup_stamp ]; then
	note "backup persistent settings"
	run-parts -a backup /usr/share/navq-persistent-storage/storage-scripts.d || \
		die "failed to backup settings"
	# mark backup is done
	touch $DATADIR/backup_stamp
	# nothing to restore, mark restore is done
	mkdir -p /var/lib/navq-persistent-storage && \
		touch /var/lib/navq-persistent-storage/restore_stamp
fi

# restore persistent data if needed
if [ ! -f /var/lib/navq-persistent-storage/restore_stamp ]; then
	note "restore persistent settings"
	run-parts -a restore /usr/share/navq-persistent-storage/storage-scripts.d || \
		die "failed to restore settings"
	# mark restore is done
	mkdir -p /var/lib/navq-persistent-storage && \
		touch /var/lib/navq-persistent-storage/restore_stamp
fi

exit 0
