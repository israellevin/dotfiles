#!/bin/dash
amixer sset Master $1
xsetroot -name "$(status.sh)"
