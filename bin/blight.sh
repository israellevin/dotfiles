#!/bin/sh
maxfile=/sys/class/backlight/intel_backlight/max_brightness
valfile=/sys/class/backlight/intel_backlight/brightness
maxlight=$(cat $maxfile)

if [ "$1" -eq "$1" ] 2> /dev/null; then
    centilight=$1
else
    curlight=$(echo "100 * $(cat $valfile) / $maxlight" | bc)
    [ "$curlight" -gt 30 ]&& centilight=20 || centilight=50
fi

newlight=$(echo "$maxlight / 100 * $centilight" | bc)

echo "$newlight" | su -c "tee '$valfile'"
