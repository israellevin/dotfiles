# X startup script.

xrandr --output eDP-1 --auto --primary # --scale 0.5x0.5
xrandr --output HDMI-1 --auto --right-of eDP-1
xmodmap ~/.xmodmap
xrdb ~/.Xresources
xset r rate 300 30 s off -dpms m 1 1
setxkbmap us,il -option grp:caps_toggle
xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Accel Speed" 0.5
pulseaudio --daemonize=1
unclutter -root &
copyq --start-server

# Lid event handler.
while true; do
    lid_state=$(head -c24 /dev/input/event1 | od -vAn -tx1 -j20 -N1)
    [ $lid_state = 01 ] && lid_close.sh || lid_open.sh
done &

# Clients startup - after monsterwm is running.
while true; do
    pgrep -x monsterwm || continue
    st -e sh -c "exec tmux attach-session -d"
    break
done &

monsterwm
