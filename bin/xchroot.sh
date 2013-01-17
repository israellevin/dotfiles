#!/bin/sh

[ "$1" ] && t="$1" || t='.'


mount -t proc none "$t/proc"
mount -t sysfs none "$t/sys"
mount -o bind /dev "$t/dev"
mount -o bind /dev/pts "$t/dev/pts"

cp ${HOME}/.xauth* $t/root/ >/dev/null 2>&1
cp ${HOME}/.Xauthority $t/root/ >/dev/null 2>&1
mkdir $t/tmp/.X11-unix/  >/dev/null 2>&1
rm -f $t/tmp/.X11-unix/X0 2>&1
ln /tmp/.X11-unix/X0 $t/tmp/.X11-unix/X0  >/dev/null 2>&1

shift
chroot $t $*

set -e
umount "$t/dev/pts"
umount "$t/dev"
umount "$t/sys"
umount "$t/proc"
