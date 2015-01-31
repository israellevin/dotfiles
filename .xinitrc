# startup - only after monsterwm is up

xmodmap ~/.xmodmap
xset r rate 300 30 s off -dpms m 1 1
setxkbmap us,il -option grp:caps_toggle

synclient TapButton1=1
synclient TapButton2=2
synclient TapButton3=3

while true; do
    pgrep -x monsterwm || continue
    urxvtd -q -o -f
    unclutter -root &
    clipit -dn &
    urxvtc -e bash -c "exec tmux attach-session -d"
    break
done &
monsterwm
