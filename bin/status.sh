#!/bin/sh
statusfile=~/.status.txt

# Print the file if it's new enough.
if [ "$(find "$statusfile" -mmin -0.1)" ]; then
    cat "$statusfile"
    exit 0
fi

# Temporarily supress output.
exec 4<&1
exec 1>/dev/null
exec 2>/dev/null

# Background check for forground color.
(
    if ! timeout 2 curl google.com >/dev/null 2>&1; then
        tmux set -g status-fg '#555555'
    elif ! pgrep ^pulseaudio; then
        tmux set -g status-fg white
        pulseaudio -D
    else
        tmux set -g status-fg green
        if echo 'info 00:12:6F:AC:37:88' | bluetoothctl | grep 'Connected: no'; then
            echo 'connect 00:12:6F:AC:37:88' | bluetoothctl
            #echo 'connect 6C:5D:63:11:95:7E' | bluetoothctl
        fi
    fi
)&

# Gather status line data.
pdate="$(date '+%H:%M %F %a')"
pmail=$(grep -Po '(?<=<fullcount>).*(?=\</fullcount>)' ~/ars/root/unreadgmail.xml)
if acpi > /dev/null; then
    pbatt=$(acpi | grep -Po '[[:digit:]]{2}:[[:digit:]]{2}(?=.*remaining)')
    [ "$pbatt" ] && pbatt="⌁$pbatt" || pbatt=⌁$(acpi | grep -o '[[:digit:]]*%')
    (if expr "$pbatt" : '⌁00:0'; then
        tmux set -g status-bg red
    else
        tmux set -g status-bg black
    fi) > /dev/null
fi
if sensors > /dev/null; then
    psens=$(sensors | grep -o '[[:digit:]]\{2\}\.[[:digit:]]' | sort -n | tail -1)°
fi
if amixer > /dev/null; then
    pvolm=$(amixer get Master | grep -om1 '[[:digit:]]*%')
fi
if mpc > /dev/null; then
    mpc status | grep "\[playing\]" > /dev/null && pplay="$(mpc current -f '[%title%]|[%file%]')"
fi

# Write status line to stdout and to file.
exec 1<&4
for item in "$pdate" $pmail $pbatt $psens $pvolm $pplay; do
    echo -n "$item "
done | awk '{if (length($0) > 60) print substr($0, 1, 59) "…"; else{sub(/.$/, ""); print;}}' | tee "$statusfile"

exit
