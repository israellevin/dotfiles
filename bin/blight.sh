#!/bin/sh
maxfile=/sys/class/backlight/intel_backlight/max_brightness
valfile=/sys/class/backlight/intel_backlight/brightness
maxlight=$(cat $maxfile)

blight() { echo "$maxlight / 10 * $1" | bc > "$valfile"; }

[ "$1" -eq "$1" ] 2>/dev/null && blight "$1" && exit 0

curlight=$(cat $valfile)
[ $(echo "10 * $curlight / $maxlight" | bc) -gt 3 ] && $0 2 || $0 5
