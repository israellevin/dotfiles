define() {
    local ret
    local lines=0
    local match
    local url="dict://dict.org"
    if [ $# -eq 0 ]; then
        echo "Usage: 'define word'"
        echo "Use specific database: 'define word db'"
        echo "Get listing of possible databases: 'define showdb'"
        echo "Word match: 'define word-part match-type' (suf, pre, sub, re)"
        echo "Suffix, prefix, substring, regular expression respectively"
        echo "If you use regular expression matching: 'define ^s.*r re'"
    fi
    if [ $# -eq 1 ]; then
        if [ $1 == "showdb" ]; then
            ret="`curl -# ${url}/show:db|tail -n +3|head -n -2|sed 's/^110.//'`"
        else
            #Lookup word
            ret="`curl -# ${url}/d:$1|tail -n +3|head -n -2|sed 's/^15[0-2].//'`"
        fi
    fi
    if [ $# -eq 2 ]; then
        case "$2" in
        "suf")
            #Match by suffix
            match="suffix"
            ret="`curl -# ${url}/m:$1::${match}|tail -n +3|head -n -2|sed 's/^15[0-2].//'`"
        ;;
        "pre")
            #Match by prefix
            match="prefix";
            ret="`curl -# ${url}/m:$1::${match}|tail -n +3|head -n -2|sed 's/^15[0-2].//'`"
        ;;
        "sub")
            #Match by substring
            match="substring";
            ret="`curl -# ${url}/m:$1::${match}|tail -n +3|head -n -2|sed 's/^15[0-2].//'`"
        ;;
        "re")
            #Regular expression match
            match="re";
            ret="`curl -# ${url}/m:$1::${match}|tail -n +3|head -n -2|sed 's/^15[0-2].//'`"
        ;;
        *)
            #Use specific databse for lookup
            ret="`curl -# ${url}/d:$1:$2|tail -n +3|head -n -2|sed 's/^15[0-2].//'`"
        ;;
        esac
    fi

    lines=`echo "${ret}"|grep -c -`

    #Output
    if [ ${lines} -gt 4 ]; then
        #Use less if more than 4 definitions
        echo "${ret}"|less -R
    else
        echo "${ret}"
    fi
}
_define(){
    local opts="re sub suf pre"
    if [ $COMP_CWORD -eq 1 ];then
        if [ -f /usr/share/dict/words ];then
            COMPREPLY=( $( grep -h "^${COMP_WORDS[COMP_CWORD]}" /usr/share/dict/words <(echo -e "showdb") ) )
        else
            COMPREPLY=( $( compgen -W "showdb" -- "${COMP_WORDS[COMP_CWORD]}"  ) )
        fi
        return 0
    elif [ $COMP_CWORD -ge 2 ];then
        COMPREPLY=( \
            $( compgen -W "$opts $(define showdb 2>/dev/null | awk '{print $1}' |\
            grep -Ev "\.|--exit--|^[0-9]*$")" -- "${COMP_WORDS[COMP_CWORD]}" ) )
        return 0
    fi
}
complete -F _define define
