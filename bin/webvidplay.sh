#!/bin/bash
fname=$(youtube-dl -t --get-filename "$1")
if [ "$fname" ]; then
    cd
    if [ -f "$fname" ]; then
        mplayer "$fname" && exit 0
    fi

    url=$(youtube-dl -g "$1")
    wget "$url" -O "$fname" &
    sleep 3
    mplayer "$fname"
else
    exit 1
fi
exit 0
