#!/usr/bin/sh

until [ -w /dev/dri/renderD128 ]; do :; done

user_path="$HOME/bin:$HOME/bin/python/bin:$HOME/bin/cargo/bin:$HOME/bin/node/bin:$HOME/bin/node/node_modules/.bin"
PATH="$user_path:$PATH:/sbin:$HOME/.fzf/bin"
LANG=en_US.UTF-8
EDITOR=vim
BROWSER=brows
export PATH
export LANG
export EDITOR
export BROWSER

WAYLAND_DISPLAY=wayland-0
XDG_CURRENT_DESKTOP=wlroots
export WAYLAND_DISPLAY
export XDG_CURRENT_DESKTOP
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

LIBSEAT_BACKEND=seatd
WLR_BACKENDS="libinput,drm"
export LIBSEAT_BACKEND
export WLR_BACKENDS
exec dwl -s ' \
    red & \
    foot & \
    brows & \
    clip --start & \
    wait'
