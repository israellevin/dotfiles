#!/bin/dash
while true
do
    if [ ! $DISPLAY ]; then
        exit;
    fi
    xsetroot -name "$(status.sh)"
    sleep 60
done
