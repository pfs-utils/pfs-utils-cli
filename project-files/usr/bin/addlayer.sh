#!/bin/sh
## addlayer, DdShurick 16.02.2017, GPL v2.
#170225 sfs
usage () {
	if [ "$1" ]; then
		echo "$0: $1"
		exit 1
	fi
	echo "Usage: addlayer n x"
	echo "	Монтирование x в n временный слой AUFS"
	echo "	n: [0-9] номер слоя aufs, созданного mkaufs"
	echo "	x: squashfs, файл с внутренней ФС ext или каталог."
	exit 0
}

[ "$1" = "" -o "$1" = "-h" -o "$1" = "--help" -o "$2" = "" ] && usage
NEWLAYER=$(realpath "$2") || usage "Файл не найден"
#if [ "$(df "$NEWLAYER" | egrep '^aufs|^unionfs')" ] ;then
#    echo "Ошибка!
#    '$2' находится на разделе с aufs. 
#    Переместите на раздел с другой файловой системой."
#    delaufs "$1" && echo "AUFS слой '$1' размонтирован." ; exit 1
#fi

[ "$(id -u)" = 0 ] || usage "Разрешено только root"
SYSMNT=$(cut -f2 -d/ /sys/fs/aufs/si_$(grep ' / aufs' /proc/mounts | cut -f2 -d= | tr ',' ' ' | cut -f1 -d' ')/br0)
AUFSMNT="/"

case "$1" in
	0) shift;;
	[1-9]) N=$1
		if [ $N -lt $(ls -d /sys/fs/aufs/si_* | wc -w) ]; then
			AUFSMNT=/$SYSMNT/aufs$N
			shift
		else
			usage "aufs с таким № нет"
		fi
	;;
	*) usage "Неверный аргумент"
esac

[ "$(grep aufs$N /proc/mounts)" ] || usage "aufs с таким № не существует"
MODNAME="$(basename "$NEWLAYER")"

if df $NEWLAYER |grep -q ^aufs ;then
	[ "$(grep $SYSMNT/tmpfs$N /proc/mounts)" ] || ( mkdir /$SYSMNT/tmpfs$N && mount -t tmpfs tmpfs /$SYSMNT/tmpfs$N )
	cp -auPR "$NEWLAYER" "/$SYSMNT/tmpfs$N/"
	NEWLAYER="/${SYSMNT}/tmpfs${N}/$(basename $NEWLAYER)"
fi

case $(file -b $NEWLAYER) in
	*directory) ;;
	Squashfs*4.0*|Linux*ext*)
		mkdir -p "/$SYSMNT/bundles$N/$MODNAME"
		mount -o loop "$NEWLAYER" "/$SYSMNT/bundles$N/$MODNAME"
		NEWLAYER="/$SYSMNT/bundles$N/$MODNAME"
	;;
	"") usage "Missing modulename" ;;
	*) usage "Invalid format $MODNAME" ;;
esac

mount -o remount,add:1:"$NEWLAYER" "$AUFSMNT" || usage "Ошибка монтирования"

echo $NEWLAYER

#[ "$AUFSMNT" = "/" ] || echo "aufs `basename $NEWLAYER` смонтирована в $AUFSMNT, сохранение изменений /$SYSMNT/changes$N"