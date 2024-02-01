#!/bin/sh

[ "$1" ] && target="$1" || target='.'
shift || true
target="$(readlink -f "$target")"
mountpoints='dev dev/pts proc sys'

# Sort and reverse sort mountpoints for mounting and unmounting.
depth() { echo "$1" | grep -o '/' | wc -l; }
depthsort() {
    for mountpoint in $mountpoints; do
        echo "$(depth "$mountpoint") $mountpoint"
    done | sort -n | cut -d' ' -f2-
}
# newlines to spaces
mountpoints="$(depthsort | sed ':a;N;$!ba;s/\n/ /g')"
reversedmountpoints="$(depthsort | tac | sed ':a;N;$!ba;s/\n/ /g')"

# Bind mountpoints.
for mountpoint in $mountpoints; do
    [ -d "/$mountpoint" ] && [ -d "$target/$mountpoint" ] && mount -B /$mountpoint "$target/$mountpoint"
done

## Copy X credentials.
cp ${HOME}/.Xauthority $target/root/ >/dev/null 2>&1
mkdir $target/tmp/.X11-unix/  >/dev/null 2>&1
rm -f $target/tmp/.X11-unix/X0 2>&1
ln /tmp/.X11-unix/X0 $target/tmp/.X11-unix/X0  >/dev/null 2>&1

## Actual chroot.
chroot "$target" "$@"

# Try to unmount any mounted mountpoints.
for mountpoint in $reversedmountpoints; do
    mount | grep -q "$target/$mountpoint" && umount "$target/$mountpoint"
done

# Warn if any mountpoints is still mounted.
for mountpoint in $reversedmountpoints; do
    mount | grep "$target/$mountpoint" && echo "$target/$mountpoint" still mounted
done

exit 0
