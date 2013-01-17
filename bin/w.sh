#!/bin/bash
if [ "$1" ]; then
    engine="$1"
    shift

    a=$*
    q=${a%-}
    [ "${a#$q}" ] && dump=yes || q=$(printf "%q" "$q")

    req="http://"
    case "$engine" in
        s) req="${req}duckduckgo.com/?q=$q";;
        g) req="${req}google.com/search?q=$q";;
        l) req="${req}google.com/search?q=$q&btnI=";;
        w) req="${req}en.wikipedia.org/w/index.php?title=Special:Search&search=$q&go=Go";;
        d) req="${req}dictionary.reference.com/browse/$q";;
        m) req="${req}morfix.nana10.co.il/$q";;
        h) req="${req}morfix.nana10.co.il/$q"; rtl=yes;;
        *) eval "w l $engine $@"; exit 0;;
    esac

    if [ "$dump" ]; then
        if [ "$rtl" ]; then
            w3m -dump $req | rev | more
        else
            w3m -dump $req | more
        fi
    else
        if [ "$rtl" ]; then
            vi "+W3m $req" "+silent Heb" "+map q <Esc>:qa!<CR>"
        else
            vi "+W3m $req" "+map q <Esc>:qa!<CR>"
        fi
    fi
else
    while read cmd; do
        eval "w $cmd -"
    done;
fi
