#!/bin/sh
#Free RAM, by «sfs» & Zay, GPL v3.
#VERSION 3.0

. /usr/bin/pfsfunc
allow_only_root

if [ "$1" ]; then
	[ -f "$1" ] && fsname="`basename $(realpath "$1")`" || fsname="$(basename "$1")"
	fullname=$(echo "${copyramdir}/${fsname}" |sed 's://:/:')
	if [ -f "$fullname" ]; then
      rm -f "$fullname"
      exitmsg "ERROR remove $fullname from RAM!" $?
	fi
else
if [ -d "${copyramdir}" ]; then
    find "${copyramdir}" -mindepth 1 -type f 2>/dev/null | while read rampfs ; do
		losetupb -a | grep -q "${rampfs}" || rm -f "$rampfs"
    done
    find "${copyramdir}" -mindepth 1 -type d -empty 2>/dev/null | while read empdir ; do
		rmdir --parents $empdir 2>/dev/null
	done
fi
fi

  
