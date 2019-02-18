#!/bin/bash
echo $((
    ${1:-100} * $(cat /sys/class/backlight/intel_backlight/max_brightness) / 100
)) > /sys/class/backlight/intel_backlight/brightness;
