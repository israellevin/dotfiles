#!/usr/bin/sh
unset TMUX
LIBSEAT_BACKEND=seatd
XDG_CURRENT_DESKTOP=wlroots
XDG_SESSION_TYPE=wayland
XDG_SESSION_DESKTOP=wlroots
export LIBSEAT_BACKEND
export XDG_CURRENT_DESKTOP
export XDG_SESSION_TYPE
export XDG_SESSION_DESKTOP

/usr/libexec/xdg-desktop-portal-wlr -r &
/usr/libexec/xdg-desktop-portal -r &

dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots

exec dwl -s ' \
    red & \
    foot & \
    brows & \
    clip --start & \
    wait'
