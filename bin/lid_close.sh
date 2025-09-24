#!/bin/sh
[ "$1" = pre ] || exit 0

bluetoothctl show | grep -q '^[[:space:]]*Powered: yes' && exit 1

pw-cli ls Node | grep -q '^[[:space:]]*application\.name = ' && exit 1
