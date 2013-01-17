#!/bin/bash
if [ "$1" ]; then
    let l="$1"
    while $((( l < 1000 )) && (( l > 0 ))) ; do let l="$l*10"
    done
    echo $l
    if [ "$2" ]; then
        redshift -l 42:44 -O $l -b 0.$2
    else
        redshift -l 42:44 -O $l
    fi
else
    pkill redshift
    redshift -x
fi
