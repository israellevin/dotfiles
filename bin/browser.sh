#!/bin/dash
if [ "$1" ]; then
    dwb -R $* &
else
    s=$(echo "0: empty
$(timeout 0.5s dwb -l)
i: chromium
n: chromium incognito" | dmenu | cut -d ' ' -f 2-)

    if [ "$s" ]; then
        if [ 'empty' = "$s" ]; then
            dwb -R &
        elif [ 'chromium' = "$s" ]; then
            sux i chromium &
        elif [ 'chromium incognito' = "$s" ]; then
            sux i chromium --incognito &
        else
            dwb -r "${s#'*'}" &
        fi
    fi
fi
exit 0
