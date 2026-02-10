#!/bin/sh
if [ "$(id -u)" -ne 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

target="$(readlink -f "${1:-.}")"
mountpoints='dev dev/pts proc sys'

# Sort and reverse sort mountpoints for mounting and unmounting.
depth() { echo "$1" | grep -o '/' | wc -l; }
depthsort() {
    for mountpoint in $mountpoints; do
        echo "$(depth "$mountpoint") $mountpoint"
    done | sort -n | cut -d' ' -f2-
}
mountpoints="$(depthsort | tr "\n" ' ')"
reversedmountpoints="$(depthsort | tac | tr "\n" ' ')"

# Bind mounts.
for mountpoint in $mountpoints; do
    [ -d "/$mountpoint" ] && [ -d "$target/$mountpoint" ] && mount -B "/$mountpoint" "$target/$mountpoint"
done

## Actual chroot.
chroot "$target"

# Try to unmount mountpoints in reverse order.
for mountpoint in $reversedmountpoints; do
    mount | grep -q "$target/$mountpoint" && umount "$target/$mountpoint"
done

# Warn if any mountpoints is still mounted.
for mountpoint in $reversedmountpoints; do
    mount | grep -Fq "$target/$mountpoint" && echo "$target/$mountpoint" still mounted && dirty=1
done

# shellcheck disable=SC2086  # We want word splitting here to ignore an empty `$dirty`.
exit $dirty
