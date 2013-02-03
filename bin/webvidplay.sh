#!/bin/bash
# dwb: Control y
fname=$(youtube-dl --no-part -t --get-filename "$1")
if [ "$fname" ]; then
    cd
    youtube-dl --no-part -t "$1" &
    sleep 3
    mplayer "$fname"
else
    exit 1
fi
exit 0
