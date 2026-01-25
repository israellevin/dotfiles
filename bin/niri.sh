#!/usr/bin/sh
until [ -w /dev/dri/renderD128 ]; do :; done
user_path="$HOME/bin"
user_path="$user_path:$HOME/bin/python/bin"
user_path="$user_path:$HOME/bin/cargo/bin"
user_path="$user_path:$HOME/bin/node/bin"
user_path="$user_path:$HOME/bin/node/node_modules/.bin"
user_path="$user_path:$HOME/.fzf/bin"
PATH="$user_path:$PATH:/sbin"
LANG=en_US.UTF-8
EDITOR=vim
BROWSER=brows
XDG_CONFIG_HOME="$HOME/.config"
XDG_CACHE_HOME="$HOME/.cache"
XDG_DATA_HOME="$HOME/.local/share"
export PATH LANG EDITOR BROWSER XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME
exec niri --session
