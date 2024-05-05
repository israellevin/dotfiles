# startup - only after monsterwm is up

xmodmap ~/.xmodmap
xrandr --output eDP-1 --auto --primary # --scale 0.5x0.5
xrandr --output HDMI-1 --auto --right-of eDP-1
xset r rate 300 30 s off -dpms m 1 1
setxkbmap us,il -option grp:caps_toggle
xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Accel Speed" 0.5

while true; do
    pgrep -x monsterwm || continue
    unclutter -root &
    copyq --start-server
    st -e sh -c "exec tmux attach-session -d"
    break
done &
monsterwm
