#!/bin/sh

[ "$1" ] && target="$1" || target='.'
shift
mountpoints='dev dev/pts proc sys'

for mountpoint in $mountpoints; do
    [ -d "/$mountpoint" ] && [ -d "$target/$mountpoint" ] && mount -B /$mountpoint "$target/$mountpoint"
done

cp ${HOME}/.xauth* $target/root/ >/dev/null 2>&1
cp ${HOME}/.Xauthority $target/root/ >/dev/null 2>&1
mkdir $target/tmp/.X11-unix/  >/dev/null 2>&1
rm -f $target/tmp/.X11-unix/X0 2>&1
ln /tmp/.X11-unix/X0 $target/tmp/.X11-unix/X0  >/dev/null 2>&1

chroot "$target" "$@"

for mountpoint in $mountpoints; do
    echo "!!! - $mountpoint"
    echo "mount | grep '$target/$mountpoint'"
    mount | grep "$target/$mountpoint"
    mount | grep "$target/$mountpoint" && umount "$target/$mountpoint"
done

for mountpoint in $mountpoints; do
    mount | grep "$target/$mountpoint" && echo "$target/$mountpoint" still mounted
done

exit 0
