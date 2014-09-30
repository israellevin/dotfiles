#!/bin/dash
export DISPLAY=':0.0'
mpwin=$(xwininfo -root -children | grep '"mpv ' | cut -c 6-13)
if [ "$mpwin" ]; then
    case $1 in
        'pause') xdotool key --window "$mpwin" space;;
        'back') xdotool key --window "$mpwin" Left Left;;
        'forward') xdotool key --window "$mpwin" Right Right;;
        'mute') xdotool key --window "$mpwin" m;;
        'volup') xdotool key --window "$mpwin" 0 0;;
        'voldown') xdotool key --window "$mpwin" 9 9;;
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
