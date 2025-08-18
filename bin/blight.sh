#!/bin/sh
maxfile=/sys/class/backlight/intel_backlight/max_brightness
valfile=/sys/class/backlight/intel_backlight/brightness
maxlight=$(cat $maxfile)

if [ "$1" -eq "$1" ] 2> /dev/null; then
    decilight=$1
else
    curlight=$(echo "10 * $(cat $valfile) / $maxlight" | bc)
    [ $curlight -gt 3 ]&& decilight=2 || decilight=5
fi

newlight=$(echo "$maxlight / 10 * $decilight" | bc)

echo "$newlight" | su -c "tee '$valfile'"
