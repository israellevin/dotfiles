#!/bin/dash
export DISPLAY=':0.0'
mp=$(xwininfo -name mpv | grep 'Window id' | cut -d ' ' -f 4)
if [ "$mp" ]; then
    case $1 in
        'pause') xdotool key --window "$mp" space;;
        'back') xdotool key --window "$mp" Left Left;;
        'forward') xdotool key --window "$mp" Right Right;;
        'mute') xdotool key --window "$mp" m;;
        'volup') xdotool key --window "$mp" 0 0;;
        'voldown') xdotool key --window "$mp" 9 9;;
    esac
else
    case $1 in
        'pause')
            s=$(mpc status | grep '\[paused\]')
            echo "* $s *"
            if [ "$s" ]; then
                mpc play
            else
                mpc pause
            fi;;
        'back') mpc prev;;
        'forward') mpc next;;
        'mute') vol toggle;;
        'volup') vol '5%+';;
        'voldown') vol '5%-';;
    esac
fi
exit 0
