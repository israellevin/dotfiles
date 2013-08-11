#!/bin/dash
if [ "$*" ]; then
    list='mpc search'
    for arg in "$@"; do
        list="$list any $arg"
    done
    list=$($list)
else
    list=$(mpc listall | dmenu)
fi

[ "$list" ] || exit 0

[ "$(mpc status | grep "\[playing\]")" ] || mpc clear

echo "$list" | mpc add
[ 0 = "$?" ] && mpc play && mpc playlist -f '%position% [[%title%[ - %album%][ (%artist%)]]|[%file%]]' || $0 $list

exit 0
