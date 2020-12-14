# startup - only after monsterwm is up

#xmodmap ~/.xmodmap
xrandr --output eDP-1 --auto --primary
xrandr --output HDMI-1 --auto --same-as eDP-1
xrandr --output HDMI-2 --auto --same-as eDP-1
xrandr --output DP-2-1 --auto --same-as eDP-1
xrandr --output DP-2-2 --auto --same-as eDP-1
#xset r rate 300 30 s off -dpms m 1 1
xset -dpms
setxkbmap us,il -option grp:caps_toggle -option terminate:ctrl_alt_bksp

synclient TapButton1=1
synclient TapButton2=2
synclient TapButton3=3

syndaemon -dtk

while true; do
    pgrep -x monsterwm || continue
    unclutter -root &
    clipmenud &
    st -e sh -c "exec tmux attach-session -d"
    break
done &
monsterwm
