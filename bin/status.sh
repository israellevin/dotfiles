#!/bin/sh
statusfile="$HOME/.status.txt"

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
    elif bluetoothctl show | grep '^[[:space:]]*Powered: yes'; then
        tmux set -g status-fg pink
    else
        tmux set -g status-fg white
    fi
) &

# Gather status line data.
line="$(date '+%H:%M %F %a')"

maxtemp=$(cat /sys/class/thermal/thermal_zone*/temp | sort -nr | head -n1)
line="$line $(( maxtemp / 1000 ))°"

vol="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | cut -d' ' -f2-)"
line="$line ${vol% \[MUTED]}"
echo "$vol" | grep -q MUTED && line="$line🔇" || line="$line📯"

battdir=/sys/class/power_supply/BAT0
battpercent=$(cat $battdir/capacity)
line="$line ${battpercent}%"
grep -q Discharging $battdir/status && line="$line🔋"

# Strong visual alert on low batt or high temp.
if [ "$battpercent" -lt 9 ] || [ "$maxtemp" -gt 90000 ]; then
    tmux set -g status-bg red
    type notify-send 2> /dev/null && notify-send -u critical "Battery low or CPU overheating!" \
        "Battery at ${battpercent}%, CPU temp at $(( maxtemp / 1000 ))°C"
else
    tmux set -g status-bg '#000000'
fi

# Write status line to stdout and to file.
printf "%s\n" "$line" | tee "$statusfile" >&4
