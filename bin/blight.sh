#!/bin/sh
maxfile=/sys/class/backlight/intel_backlight/max_brightness
valfile=/sys/class/backlight/intel_backlight/brightness
kbdfile='/sys/class/leds/tpacpi::kbd_backlight/brightness'

maxlight=$(cat $maxfile)

if [ "$2" -eq "$2" ] 2> /dev/null; then
    kbdlight=$2
else
    kbdlight=0
fi

if [ "$1" -eq "$1" ] 2> /dev/null; then
    centilight=$1
else
    curlight=$(echo "100 * $(cat $valfile) / $maxlight" | bc)
    if [ "$1" = "up" ]; then
        centilight=$(echo "$curlight + 10" | bc)
    elif [ "$1" = "down" ]; then
        centilight=$(echo "$curlight - 10" | bc)

    # For default action, toggle between 20% and 50% brightness and kyeboard backlight.
    elif [ "$curlight" -gt 30 ]; then
            centilight=20
            kbdlight=1
    else
        centilight=50
        kbdlight=0
    fi
fi

echo "$maxlight / 100 * $centilight" | bc | su -c "tee '$valfile'"
echo "$kbdlight" | su -c "tee '$kbdfile'"
