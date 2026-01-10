#!/bin/bash
for f in .* .config/*/* bin/*; do
    [ -f "$f" ] || continue

    if ! [ -f "$HOME/$f" ]; then
        create=y
        read -rn1 -p "$f not found in home. Copy from repo? [Y/n] " create && echo
        [ "$create" != n ] && cp -a "$f" "$HOME/$f" && echo "Created $HOME/.$f"
        continue
    fi

    [ "$(diff {.,$HOME}/"$f")" ] || continue

    show=y
    read -n1 -p "$f differs from home. Show diff? [Y/n] " show && echo
    [ "$show" != n ] && vimdiff {.,$HOME}/"$f"
done
