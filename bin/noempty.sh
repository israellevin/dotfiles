#!/bin/sh
get() {
    niri msg --json "$1" | jq -r "$2"
}
workspace_id="$(get workspaces '.[] | select(.is_focused == true) | .id')"
[ "$workspace_id" ] || exit 0
num_of_windows="$(get windows '[.[] | select(.workspace_id == '"$workspace_id"') ] | length')"
[ "$num_of_windows" = 0 ] && niri msg action focus-window-previous
