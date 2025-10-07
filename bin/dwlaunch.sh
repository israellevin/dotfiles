#!/usr/bin/sh

until [ -w /dev/dri/renderD128 ]; do :; done

user_path="$HOME/bin:$HOME/bin/python/bin:$HOME/bin/cargo/bin:$HOME/bin/node/bin:$HOME/bin/node/node_modules/.bin"
PATH="$user_path:$PATH:/sbin:$HOME/.fzf/bin"
LANG=en_US.UTF-8
EDITOR=vim
BROWSER=brows
WAYLAND_DISPLAY=wayland-0
XDG_CURRENT_DESKTOP=wlroots
WLR_BACKENDS=libinput,drm
export PATH LANG EDITOR BROWSER WAYLAND_DISPLAY XDG_CURRENT_DESKTOP WLR_BACKENDS

systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

exec dwl -s ' \
    red & \
    foot & \
    clip --start & \
    brows --wait-till-online & \
    wait'
