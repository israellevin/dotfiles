#!/usr/bin/sh
until [ -w /dev/dri/renderD128 ]; do :; done
user_path="$HOME/bin:$HOME/bin/python/bin:$HOME/bin/cargo/bin:$HOME/bin/node/node_modules/.bin"
PATH="$user_path:$PATH:/sbin:$HOME/bin/node/bin:$HOME/.fzf/bin"
LANG=en_US.UTF-8
EDITOR=vim
BROWSER=brows
export PATH LANG EDITOR BROWSER
exec niri
