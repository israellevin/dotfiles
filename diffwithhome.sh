#!/bin/bash
for f in .* bin/*; do [ -f "$f" ] && [ "$(diff {./,~/}"$f")" ] && read -p "$f" && vimdiff {./,~/}"$f"; done
