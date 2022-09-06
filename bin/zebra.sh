#!/bin/bash
ALTERNATE=$'\001'"$(tput setab 1)"$'\002'
RESET=$'\001'"$(tput sgr0)"$'\002'
while read line; do
    echo "$ALTERNATE$line$RESET"
    read line
    echo "$line"
done
