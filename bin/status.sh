#!/bin/sh
(
    if expr "$pbatt" : '⌁00:0'; then
        tmux set -g status-fg red
    elif ! pgrep ^pulseaudio; then
        tmux set -g status-fg white
    else
        tmux set -g status-fg green
    fi

    if ! timeout 2 ping -w1 google.com >/dev/null 2>&1; then
        tmux set -g status-bg '#555555'
    else
        tmux set -g status-bg default
    fi
) 2>&1 > /dev/null &

(
    pdate="$(date '+%H:%M %F %a')"
    pmail=$(grep -Po '(?<=<fullcount>).*(?=\</fullcount>)' ~/ars/root/unreadgmail.xml)
    if acpi > /dev/null; then
        pbatt=$(acpi | grep -Po '[[:digit:]]{2}:[[:digit:]]{2}(?=.*remaining)')
        [ "$pbatt" ] && pbatt="⌁$pbatt" || pbatt=⌁$(acpi | grep -o '[[:digit:]]*%')
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
    for item in "$pdate" $pmail $pbatt $psens $pvolm $pplay; do
        echo -n "$item "
    done
) 2> /dev/null | awk '{if (length($0) > 60) print substr($0, 1, 59) "…"; else{sub(/.$/, ""); print;}}'

exit 0
