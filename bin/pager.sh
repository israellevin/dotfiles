#!/bin/dash
[ -f "$1" ] && cat "$1" | $0 && exit
i=0
lines=''
while read l && [ $i -lt 50 ]; do
    i=$((i+1))
    lines="$lines\n$l"
done

(echo $lines && while read l; do echo $l; done) | ([ "$l" ] && less || (cut -c 1-$(tput cols) | more))
