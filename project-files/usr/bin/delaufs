#!/bin/sh
## delaufs, DdShurick 18.02.2017, GPL v2.
#170224 sfs

usage() {
	if [ "$1" ]; then
		echo "$0: $1"
		exit 1
	fi
	echo "Использовать: delaufs [1-9]"
	echo " аргумент - № удаляемой aufs"
	exit 0
}

[ "$1" = "" -o "$1" = "-h" -o "$1" = "--help" ] && usage
[ "$(id -u)" = 0 ] || usage "Разрешено только root"
#Закомментил проверку, чтоб остатки сломанных ауфс удалял тоже
#N=$(ls /sys/fs/aufs/ |egrep '^si_' | wc -w) #количество aufs
#[ "$1" -gt 0 -a "$N" -gt "$1" ] || usage "Неправильный аргумент"
SYSMNT=$(cut -f2 -d/ /sys/fs/aufs/si_$(grep ' / aufs' /proc/mounts | cut -f2 -d= | tr ',' ' ' | cut -f1 -d' ')/br0)

umount /$SYSMNT/aufs$1 2>/dev/null
rmdir /$SYSMNT/aufs$1 

if [ "$(grep changes$1 /proc/mounts)" ]; then
	umount -d /$SYSMNT/changes$1
	rmdir /$SYSMNT/changes$1
else
	rm /$SYSMNT/changes$1
fi 2>/dev/null

if [ "$(grep tmpfs$1 /proc/mounts)" ]; then
	umount /$SYSMNT/tmpfs$1
	rmdir /$SYSMNT/tmpfs$1
else
	rmdir /$SYSMNT/tmpfs$1
fi 2>/dev/null


if [ -d /$SYSMNT/bundles$1 ]; then
	ls -1 /$SYSMNT/bundles$1 | while read D
	do
		umount -d /$SYSMNT/bundles$1/$D
		rmdir /$SYSMNT/bundles$1/$D
	done
	 rmdir /$SYSMNT/bundles$1
fi 2>/dev/null
