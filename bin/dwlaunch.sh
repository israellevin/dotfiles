#!/usr/bin/sh
user_path="$HOME/bin:$HOME/bin/python/bin:$HOME/bin/cargo/bin:$HOME/bin/node/bin:$HOME/bin/node/node_modules/.bin"
PATH="$user_path:$PATH:/sbin:$HOME/.fzf/bin"
LANG=en_US.UTF-8
EDITOR=vim
BROWSER=brows
LIBSEAT_BACKEND=seatd
WLR_BACKENDS="libinput,drm"
XDG_CURRENT_DESKTOP=dwl
export PATH
export LANG
export EDITOR
export BROWSER
export LIBSEAT_BACKEND
export WLR_BACKENDS
export XDG_CURRENT_DESKTOP

until [ -w /dev/dri/renderD128 ]; do :; done

exec dwl -s ' \
    red & \
    foot & \
    brows & \
    clip --start & \
    /usr/libexec/xdg-desktop-portal-wlr & \
    wait'
