# startup - only after monsterwm is up

xmodmap ~/.xmodmap
xrandr --output eDP-1 --auto --primary
xrandr --output HDMI-1 --auto --right-of eDP-1
xset r rate 300 30 s off -dpms m 1 1
setxkbmap us,il -option grp:caps_toggle

synclient TapButton1=1
synclient TapButton2=2
synclient TapButton3=3

syndaemon -dtk

while true; do
    pgrep -x monsterwm || continue
    unclutter -root &
    copyq &
    st -e sh -c "exec tmux attach-session -d"
    break
done &
monsterwm
