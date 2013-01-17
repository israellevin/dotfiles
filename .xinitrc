# startup - only after monsterwm is up
while true; do
    pgrep -x monsterwm || continue
    xmodmap ~/.xmodmap
    xset r rate 300 30 s off -dpms m 1 1
    setxkbmap us,il -option grp:caps_toggle
    urxvtd -q -o -f
    unclutter -root &
    clipit -dn &
    urxvtc &
    break
done &

# capture monsterwm's stdout
ff='/tmp/monsterwm.fifo'
[ -p $ff ] || mkfifo -m 600 "$ff"
monsterwm | tee "$ff"
