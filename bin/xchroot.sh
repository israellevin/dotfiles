#!/bin/dash

[ "$1" ] && t="$1" || t='.'
shift

mount -B /dev "$t/dev"
mount -B /sys "$t/sys"
mount -B /proc "$t/proc"
mount -B /dev/pts "$t/dev/pts"

cp ${HOME}/.xauth* $t/root/ >/dev/null 2>&1
cp ${HOME}/.Xauthority $t/root/ >/dev/null 2>&1
mkdir $t/tmp/.X11-unix/  >/dev/null 2>&1
rm -f $t/tmp/.X11-unix/X0 2>&1
ln /tmp/.X11-unix/X0 $t/tmp/.X11-unix/X0  >/dev/null 2>&1

chroot $t $*

set -e
umount "$t/dev/pts"
umount "$t/proc"
umount "$t/sys"
umount "$t/dev"

exit 0
