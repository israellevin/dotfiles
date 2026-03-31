#!/usr/bin/sh
if [ "$1" ]; then
    window_id="$(niri msg --json windows | jq -r '.[] | select(
        (.title // "" | test("qute"; "i")) or (.app_id // "" | test("qute"; "i"))
    ) | .id')"
else
    window_id="$( \
        niri msg --json windows | \
        jq -r '.[] | "\(.id): \(.title) (\(.app_id))"' | \
        menu | \
        cut -d: -f1)"
fi
if [ "$window_id" ]; then
    niri msg action focus-window --id "$window_id"
else
    echo "No window selected" >&2
    exit 1
fi
