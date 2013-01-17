#!/bin/dash
cmxtypes="zip\|rar\|cbz\|cbr"
cmxread="/home/i/read"

cmx="$(tac $cmxread | awk '!x[$0]++' | head -n 20)
$(find /media/Tera/pub/comics -type f -iregex ".*\.\($cmxtypes\)")"

cmx=$(echo "$cmx" | dmenu)

if [ "$cmx" ]; then
    echo $cmx >> $cmxread
    comix -f "$cmx"
fi
