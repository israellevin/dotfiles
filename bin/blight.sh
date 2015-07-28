#!/bin/bash
blight() {
    echo $((
        $1 * $(cat /sys/class/backlight/intel_backlight/max_brightness) / 100
    )) > /sys/class/backlight/intel_backlight/brightness;
}

[ "${BASH_SOURCE[0]}" = "$0" ] && blight $1 || true
