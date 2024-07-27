#!/bin/sh
DISPLAY="$(ps -euww | grep -Po '(?<=DISPLAY=)[^ ]*' | tail -1)"
XAUTHORITY="$(ps -euww | grep -Po '(?<=XAUTHORITY=)[^ ]*' | tail -1)"
export DISPLAY
export XAUTHORITY
xdotool key 'alt+ctrl+F1'
echo mem > /sys/power/state
