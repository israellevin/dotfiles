#!/bin/bash
q="$(echo "$@" | tr ' ' '+')"
q="http://google.com/search?q=site:lyrics.wikia.com+$q&btnI"
curl -e "http://www.google.com" -A "Mozilla/4.0" -skL "$q" | w3m -T text/html | while read line; do
    if [ 'print' = "$q" ]; then
        grep 'linksNominate' <<<"$line" &>/dev/null && break
        echo "$line"
    else
        grep 'music Gracenote' <<<"$line" &>/dev/null && q=print
    fi
done | v
