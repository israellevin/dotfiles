#!/bin/dash
cmxtypes='zip\|rar\|cbz\|cbr'
cmxlist='/home/i/comix'
tmp='/tmp/vids'

dolist() {
    find ~pub/comics ~/torrents -type f -iregex ".*\\.\\($cmxtypes\\)")"
}

[ -f "$cmxlist" ] || dolist > "$cmxlist"
cmx=$(cat "$cmxlist" | dmenu)

if [ -f "$cmx" ]; then
    comix -f "$cmx"
    echo $cmx > $tmp
fi

cat "$cmxlist" >> "$tmp"
dolist >> "$tmp"
awk '!x[$0]++' "$tmp" > "$cmxlist"

exit 0
