#!/bin/bash
REVERSE="$(tput rev)"
CLEAR="\e[m"
while read line; do
    printf "\x1b[48;5;%sm%s\e[0m\n" 52 "$line"
    read line
    printf "%s\n" "$line"
done
