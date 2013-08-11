#!/bin/dash
curl -e "http://www.google.com" -A "Mozilla/4.0" -skL "http://google.com/search?q=site:azlyrics.com+$(echo "$@" | tr ' ' '+')&btnI" | awk '
    /<!-- start of lyrics -->/, /<!-- end of lyrics -->/ {
        gsub("<[^>]*>", "")
        gsub(/\r/, "")
        print "  " $0
    }
' | p
exit 0
