#!/bin/bash
vidtypes='3g.\|asf\|asx\|avi\|bin\|divx\|dvx\|f4v\|flc\|flv\|gvi\|m4v\|mkv\|mov\|mp4\|mpeg\|mpg\|ogm\|qt\|rm\|swf\|vid\|wmv\|xvid'
watched='/home/i/watched'

vids="$(tac $watched | awk '!x[$0]++' | head -n 50)
$(find /media/Tera/pub/{audio,cinema,TV,video,Xbu} ~/torrents -type f -iregex ".*\\.\\($vidtypes\\)")
dvd://
dvdnav://"

vid=$(echo "$vids" | dmenu)

if [ -f "$vid" ]; then
    DISPLAY=':0.0' TMUX='' tmux new-session -d "mplayer '$vid'" && echo "$vid" >> $watched
fi

exit 0
