#!/bin/dash
cd
youtube-dl -t --no-part "$1" &
f=$(youtube-dl -t --get-filename "$1")
sleep 3 && [ -f "$f" ] && mpv "$f"
wait
exit 0
