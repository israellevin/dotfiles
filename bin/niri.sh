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
export PATH LANG EDITOR BROWSER
exec niri --session
