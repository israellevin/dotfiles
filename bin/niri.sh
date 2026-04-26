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
QT_QPA_PLATFORM=wayland
export PATH LANG EDITOR BROWSER QT_QPA_PLATFORM

log_dir="$HOME/.local/share/niri/logs"
mkdir -p "$log_dir"
find "$log_dir" -type f -name "*.log" -printf '%T@ %p\n' | sort -nr | tail -n +3 | cut -d' ' -f2- | xargs rm -f

exec niri --session 2>&1 | tee -a "$log_dir/$(date +%Y-%m-%d-%H-%M-%S).log"
