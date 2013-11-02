#!/bin/bash
# mntnir.sh - the CLI volume manager
# by: Israel Levin
# Public Domain

# Parse dbus results
function parse
{
    # Get to the data if given a full response
    [ 'method' = "$1" ] && [ 'variant' = "$7" ] && shift 7 || shift 6

    # Remove quotes from string
    if [ 'string' = "$1" ]; then
        t="${@:2}"
        echo "${t//\"/}"

    # Parse array
    elif [ 'array' = "$1" ]; then
        shift 2
        while [ "$2" ]; do

            # Objects have a name and then a value
            if [ 'object' = "$1" ]; then
                parse $1 $2 $3
                shift 3
            else
                parse ${@:1:$# - 1}
                shift 2
            fi
        done

    # Objects also have quotes
    elif [ 'object' = "$1" ]; then
        t="${@:3}"
        echo "${t//\"/}"

    # Otherwise just print it
    else
        echo "$2"
    fi
}

# Query values from UDisks device via dbus
function query
{
    parse $(dbus-send --system --print-reply --dest=org.freedesktop.UDisks "$1" org.freedesktop.DBus.Properties.Get string:org.freedesktop.UDisks.Device string:"$2")
}

# Case insensitive matching
function matchi
{
    local s; s=$(tr '[:upper:]' '[:lower:]' <<< $1)
    local p; p=$(tr '[:upper:]' '[:lower:]' <<< $2)
    local r; r=${s/${p}*/}
    [ ${#r} -eq ${#s} ] && echo -1 || echo "${#r}"
}

# Turn number of bytes into human readable size
function humanify
{
    awk '{split("B kB MB GB TB PB",v); s=1; while($1>1000){$1/=1000; s++} print int($1)v[s]}' <<< $1
}

# Accept commands from stdin
if [ '-' = "$*" ]; then
    while read command; do
        if [ 'q' = "$command" ]; then
            break
        elif [ '-' != "$command" ]; then
            $0 $command
        fi
    done

else
    declare -a vols

    for vol in $(parse $(dbus-send --system --print-reply --dest=org.freedesktop.UDisks /org/freedesktop/UDisks org.freedesktop.UDisks.EnumerateDevices)); do

        # Filter non-fs and hidden
        [ 'filesystem' != "$(query "$vol" IdUsage)" ] && continue
        [ 'false' != "$(query "$vol" DevicePresentationHide)" ] && continue

        # Get volume data
        dev=$(query "$vol" DeviceFile)
        lbl=$(query "$vol" IdLabel)
        siz=$(humanify $(query "$vol" DeviceSize))
        fst=$(query "$vol" IdType)
        if [ 'true' = "$(query "$vol" DeviceIsMounted)" ]; then
            mnt='mounted'
            [ 'true' = "$(query "$vol" DeviceIsReadOnly)" ] && mnt="$mnt (RO)"
            pth=$(query "$vol" DeviceMountPaths)
            mnt="$mnt on \"${pth[*]}\""
        else
            mnt='not mounted'
        fi

        # Filter non-matches
        [ "$1" ] && [ $(matchi "${dev}${lbl}${fst}${siz}${mnt}" "$1") -eq -1 ] && continue

        vols=( ${vols[*]} "$vol" )
        cur_mnt="$mnt"
        cur_dev="$dev"

        # Prepare output string
        [ ${#vols[*]} -gt 1 ] && s+="\n"
        s+=$(echo "$dev : \"$lbl\" $siz $fst $mnt" | tr -s " ")
    done

    # Multiple volumes matched, output information about them
    if [ ${#vols[*]} -gt 1 ]; then
        echo -en "$s"

    # Single volume matched, proceed to actions
    elif [ ${#vols[*]} -eq 1 ]; then
        vol=${vols[0]}
        dev="$cur_dev"
        mnt="$cur_mnt"
        declare -a acts
        [ 'not mounted' = "$mnt" ] && acts[0]='mount' || acts[0]='umount'
        [ 'true' = $(query "$vol" DriveCanDetach) ] && acts[1]='detach'
        [ 'true' = $(query "$vol" DriveIsMediaEjectable) ] && acts=( ${acts[*]-} 'eject' )

        # Filter non-matches to action argument
        if [ "$2" ]; then
            len=${#acts[*]}
            for (( i=0; i<$len; i++ )); do
                [ $(matchi "${acts[$i]}" "$2") -ne 0 ] && unset acts[$i]
            done

            # Single actions matched, make it so
            if [ ${#acts[*]} -eq 1 ]; then
                if [ 'mount' = ${acts[*]} ]; then
                    r=$(dbus-send --system --print-reply --dest=org.freedesktop.UDisks "$vol" org.freedesktop.UDisks.Device.FilesystemMount string:"" array:string:"" 2>&1)
                    [ $? -eq 0 ] && echo "$dev mounted on $(parse $r)" || echo "$r"
                elif [ 'umount' = ${acts[*]} ]; then
                    r=$(dbus-send --system --print-reply --dest=org.freedesktop.UDisks "$vol" org.freedesktop.UDisks.Device.FilesystemUnmount array:string:"" 2>&1)
                    [ $? -eq 0 ] && echo "$dev unmounted" || echo "$r"
                elif [ 'detach' = ${acts[*]} ]; then
                    r=$(dbus-send --system --print-reply --dest=org.freedesktop.UDisks "$vol" org.freedesktop.UDisks.Device.DriveDetach array:string:"" 2>&1)
                    [ $? -eq 0 ] && echo "$dev detached" || echo "$r"
                elif [ 'eject' = ${acts[*]} ]; then
                    r=$(dbus-send --system --print-reply --dest=org.freedesktop.UDisks "$vol" org.freedesktop.UDisks.Device.DriveEject array:string:"unmount" 2>&1)
                    [ $? -eq 0 ] && echo "$dev ejected" || echo "$r"
                fi

            # No actions matched, try without pattern
            elif [ ${#acts[*]} -eq 0 ]; then
                $0 $1
            fi
            exit 0
        fi

        # Print matching actions
        for act in ${acts[*]}; do
            echo "$dev $act"
        done

    # No volumes matched, try without pattern
    elif [ "$1" ]; then
        $0

    # No volumes found at all, something must be wrong
    else
        exit 127
    fi
fi
exit 0
