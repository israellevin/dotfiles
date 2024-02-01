#!/bin/sh
hide() {
    DISPLAY="$(ps -euww | grep -Po '(?<=DISPLAY=)[^ ]*' | tail -1)"
    XAUTHORITY="$(ps -euww | grep -Po '(?<=XAUTHORITY=)[^ ]*' | tail -1)"
    export DISPLAY
    export XAUTHORITY
    xdotool key 'alt+ctrl+F1'
}

if [ "$1" = pre ]; then
    xrandr | grep -q 'HDMI-1 connected' && exit 1
    hide
    grep -q RUNNING /proc/asound/*/*/*/status && exit 1
fi

exit 0
