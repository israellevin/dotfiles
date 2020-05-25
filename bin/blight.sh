#!/bin/bash
brightnessfile=/sys/class/backlight/intel_backlight/brightness
maxfile=/sys/class/backlight/intel_backlight/max_brightness
max=$(cat $maxfile)
echo $(($(if [ "$1" ]; then
    echo "$1"
else
    if [ $max -eq $(cat $brightnessfile) ]; then
        echo 1
    else
        echo 100
    fi
fi) * max / 100)) > $brightnessfile
