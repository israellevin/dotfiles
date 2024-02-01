#!/usr/bin/bash
target_windown_name="$@"
target_window_id=$(xdotool search --name "$target_windown_name" | head -1)
[ "$target_window_id" ] || exit 1
starting_window_id=$(xdotool getactivewindow)
while [ "$(xdotool getactivewindow)" != "$target_window_id" ]; do
    xdotool key super+j
    [ "$(xdotool getactivewindow)" = "$starting_window_id" ] && exit 2
done
exit 0
