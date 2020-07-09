#!/bin/sh
statusfile=~/.status.txt

# Supress ordinary output.
exec 4<&1
exec 1>/dev/null
exec 2>/dev/null

# Print the file if it's new enough.
if [ "$(find "$statusfile" -mmin -0.1)" ] && [ -z "$(find "$statusfile" -newermt '1 minute')" ]; then
    cat "$statusfile" 1>&4
    exit 0
fi

# Background check for forground color.
(
    if ! timeout 2 curl google.com; then
        tmux set -g status-fg '#555555'
    elif ! pgrep ^pulseaudio; then
        tmux set -g status-fg white
        pulseaudio -D
    elif ! /etc/init.d/bluetooth status; then
        tmux set -g status-fg white
    elif echo 'info 00:12:6F:AC:37:88' | bluetoothctl | grep 'Connected: yes'; then
        tmux set -g status-fg green
    elif echo 'info 99:B7:CA:AB:85:72' | bluetoothctl | grep 'Connected: yes'; then
        tmux set -g status-fg cyan
    else
        tmux set -g status-fg yellow
        echo 'connect 00:00:00:00:00:00' | bluetoothctl
    fi
)&

# Gather status line data.
pdate="$(date '+%H:%M %F %a')"
if acpi; then
    if acpi | grep Discharging; then
        pbatt=$(acpi | grep -Po '[[:digit:]]{2}:[[:digit:]]{2}')🔋
        if expr "$pbatt" : '00:0'; then
            tmux set -g status-bg red
        else
            tmux set -g status-bg black
        fi
    else
        pbatt=$(acpi | grep -Po '[[:digit:]]{1,3}%')⌁
        tmux set -g status-bg black
    fi
    pbatt="$pbatt"
else
    base=/sys/class/power_supply/BAT0
    capacity=$(cat $base/capacity)
    [ $capacity -lt 09 ] && tmux set -g status-bg red || tmux set -g status-bg black
    grep 'Discharging' $base/status && pbatt="$capacity%🔋" || pbatt="$capacity%⌁"
fi

if sensors; then
    psens=$(sensors | grep -o '[[:digit:]]\{2\}\.[[:digit:]]' | sort -n | tail -1)°
fi

if amixer; then
    pvolm=$(amixer get Master | grep -om1 '[[:digit:]]*%')
fi

# Write status line to stdout and to file.
for item in "$pdate" $pvolm $psens $pbatt; do
    echo -n "$item "
done | awk '{if (length($0) > 60) print substr($0, 1, 59) "…"; else{sub(/.$/, ""); print;}}' | tee "$statusfile" 1>&4

exit
