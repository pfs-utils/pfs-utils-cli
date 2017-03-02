#!/bin/sh
## mkaufs, DdShurick 14.02.2017, GPL v2. The idea of betcher.
#170224 sfs

usage () {
	if [ "$1" ]; then
		echo "$0: $1"
	else
		echo "Использовать:"
		echo "	$0 - изменения сохраняются в tmpfs"
		echo "	$0 <раздел> <каталог> - изменения сохраняются в каталог на указанном разделе"
		echo "		раздел - \"home|sd[a-f][1-9]*\""
		echo "		каталог - любое имя без пробела"
	fi
	exit 0
}

[ "$(id -u)" = 0 ] || usage "Разрешено только root"

#N=$(ls /sys/fs/aufs/ | wc -w) # № для aufs если несколько.
N=$(ls /sys/fs/aufs/ |egrep '^si_'| wc -w) # № для aufs если несколько.
SYSMNT=$(cut -f2 -d/ /sys/fs/aufs/si_$(grep ' / aufs' /proc/mounts | cut -f2 -d= | tr ',' ' ' | cut -f1 -d' ')/br0)

if [ $# = 0 ]; then
	mkdir /$SYSMNT/changes$N
	mount -t tmpfs tmpfs /$SYSMNT/changes$N
elif [ $# = 2 ]; then
	MNTPT="$(grep $1 /proc/mounts | awk '{print $2}')" 
	if [ "$MNTPT" = "" ]; then
		[ "$(grep $1 /proc/partitions)" ] || usage "Такого раздела не существует"
		[ "$(blkid $DEV | grep ext)" ] || usage "ФС не Linux"
		MNTPT=/mnt/$1
		mkdir $MNTPT
		mount /dev/$1 $MNTPT
	fi
	mkdir $MNTPT/$2
	ln -s $MNTPT/$2 /$SYSMNT/changes$N
else
	usage
fi

mkdir /$SYSMNT/aufs$N
mount -t aufs -o dirs=/$SYSMNT/changes$N/=rw aufs /$SYSMNT/aufs$N && echo "/$SYSMNT/aufs$N" || exit 1
