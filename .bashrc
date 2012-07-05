# Don't do shit if not connected to a terminal
[ -t 0 ] || return

# Multiplex
[ ! "$TMUX" ] && tmux -2 new-session && [ ! -e /tmp/dontquit ] && exit 0

# Show stats bar for remote connections
[ "$SSH_CONNECTION" ] && tmux set status on

# Steal all tmux windows into current session
function muxjoin {
    [ ! "$TMUX" ] && echo 'tmux not running' 1>&2 && exit 1
    tmux set status on
    for win in $(tmux list-windows -a | cut -d : -f 1-2); do
        tmux move-window -d -s "$win"
    done
}

# Split current tmux session to multiple X terminals
function muxsplit {
    [ ! "$TMUX" ] && echo 'tmux not running' 1>&2 && exit 1
    tmux rename-session split
    [ ! "$?" ] && echo 'split session exists' 1>&2 && exit 1
    for win in $(tmux list-windows -t split | cut -d : -f 1); do
        TMUX='' urxvtcd -e dash -c "tmux new-session \\; move-window -k -s 'split:$win' -t 0"
    done
}

alias muxheist='muxjoin && muxsplit'

# Make nice
renice -n -10 -p "$$" > /dev/null

# Create a new group for this session
mkdir -pm 0700 /sys/fs/cgroup/cpu/user/$$
echo $$ > /sys/fs/cgroup/cpu/user/$$/tasks

# Shell options
shopt -s cdspell
shopt -s dotglob
shopt -s cmdhist
shopt -s nocaseglob
shopt -s histappend
shopt -s histreedit
shopt -s histverify
shopt -s checkwinsize
shopt -u force_fignore
shopt -s no_empty_cmd_completion
export IGNOREEOF=1

# History
export HISTFILESIZE=999999
export HISTSIZE=999999
export HISTCONTROL=erasedups,ignoreboth
export HISTTIMEFORMAT='%F %T '
export HISTIGNORE='&:exit'
export PROMPT_COMMAND='history -a; history -n'

# Completion
source /etc/bash_completion
complete -W "$(echo $(grep '^ssh ' .bash_history | sort -u | sed 's/^ssh //'))" ssh
_fasd_bash_hook_cmd_complete j vv mm
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



# Filesystem traversal
export PATH="$HOME/bin:$PATH"
#export CDPATH='.:~'
cd() { [ -z "$1" ] && set -- ~; [ "$(pwd)" != "$(readlink -f "$1")" ] && pushd "$1"; }
..() { if [ $1 -ge 0 2> /dev/null ]; then x=$1; else x=1; fi; for (( i = 0; i < $x; i++ )); do cd ..; done; }
mkcd() { mkdir -p "$*"; cd "$*"; }
alias b='popd'
alias m='mntnir.sh'
alias d='trash-put'
alias dud='du --max-depth=1 -h | sort -h'
eval "$(fasd --init auto)"
fasd_cd() { [ $# -gt 1 ] && cd "$(fasd -e echo "$@")" || fasd "$@"; }
alias j='fasd_cd -d'
alias f='fasd -f'

# ls
export LS_OPTIONS='-lh --color=auto'
alias l="ls $LS_OPTIONS"
alias ll="ls $LS_OPTIONS -A"
alias lt="ls $LS_OPTIONS -tr"
alias ld="ls $LS_OPTIONS -A -d */"
alias lss="ls $LS_OPTIONS -Sr"

# grep
export GREP_OPTIONS='-i --color=auto'
alias lg='ll | grep'
alias fgg='find | grep'
alias pg='ps -ef | grep -v grep | grep'

# vim
alias v='fasd -e vim -b viminfo'
vv() { [ -z $1 ] && vim -c "normal '0" || vim -p *$**; }
vg() { vim -p $(grep -l "$*" *); }
alias vf='find && vim -c "CtrlP"'
alias vs='vim -c "set spell | set buftype=nofile"'

# Media
alias d0='DISPLAY=":0.0"'
alias d1='DISPLAY="localhost:10.0"'
alias mp='mplayer'
alias mpl='mplayer -lavdopts lowres=1:fast:skiploopfilter=all'
alias mpy='mplayer -vf yadif'
alias feh='feh -ZF'
mplen() { wf `mplayer -vo dummy -ao dummy -identify "$1" 2>/dev/null | grep ID_LENGTH | cut -c 11-` seconds to minutes; }

# Web
alias webshare='python -c "import SimpleHTTPServer;SimpleHTTPServer.test()"'
alias wclip='curl -F "sprunge=<-" http://sprunge.us | xclip -f'
t() {
    [ 'q' = "$1" ] && return $(killall deluged)
    if [ ! "$(pgrep deluged)" ]; then
        read -q "?Daemon not running, abort? " && return 0
        deluged && echo ' Starting daemon' && sleep 1
    fi
    case "$1" in
        a) cmd='add';;
        p) cmd='pause';;
        r) cmd='resume';;
        f) cmd='follow';;
        t) cmd='throttle';;
        *) cmd='';;
    esac
    if [ "$cmd" ]; then
        shift
        if [ 'follow' = "$cmd" ]; then
            watch -n 0.5 "deluge-console 'info --sort-reverse=state $@' | tail -n 8"
        elif [ 'throttle' = "$cmd" ]; then
            if [ ' -1.0' = "$(deluge-console 'config max_upload_speed' | cut -d ':' -f 2)" ]; then
                deluge-console 'config -s max_upload_speed 90'
                deluge-console 'config -s max_download_speed 900'
            else
                deluge-console 'config -s max_upload_speed -1'
                deluge-console 'config -s max_download_speed -1'
            fi
        else
            deluge-console "$cmd $@"
        fi
        while [ "$@" ]; do shift; done
    fi
    deluge-console "info --sort-reverse=progress $@"
    deluge-console 'config max_upload_speed'
    deluge-console 'config max_download_speed'
}
w() {
    if [ '-d' = "$1" ]; then
        local opts='-dump | more'
        shift
    fi
    if [ "$1" ]; then
        local query='http://'
        local engine="$1"
        shift
        case "$engine" in
            s) query="${query}duckduckgo.com/?q=$*";;
            g) query="${query}google.com/search?q=$*";;
            l) query="${query}google.com/search?q=$*&btnI=";;
            w) query="${query}en.wikipedia.org/w/index.php?title=Special:Search&search=$*&go=Go";;
            d) query="${query}dictionary.reference.com/browse/$*";;
            m)
                if [ 'h' = "$1" ]; then
                    shift
                    opts="-dump | rev | more"
                fi
                query="${query}morfix.nana10.co.il/$*"
            ;;
        esac
        local cmd="w3m '$query' $opts"
        eval $cmd
    else
        while read cmd; do
            eval "w -d $cmd"
        done;
    fi
}
wf() { w3m "http://m.wolframalpha.com/input/?i=$(perl -MURI::Escape -e "print uri_escape(\"$*\");")" -dump 2>/dev/null | grep -A 2 'Result:' | tail -n 1; }
wf() { wget -O - "http://api.wolframalpha.com/v1/query?input=$*&appid=LAWJG2-J2GVW6WV9Q" 2>/dev/null | grep plaintext | sed -n 2,4p | cut -d '>' -f2 | cut -d '<' -f1; }
wff() { while read r; do wf $r; done; }

# General aliases and functions
alias x='TMUX="" startx &'
log() { $@ 2>&1 | tee log.txt; }

# Colors
eval "`dircolors`"
export LESS='-MR'
export LESS_TERMCAP_us=$'\e[32m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'

# Prompt
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
#PS1='u@\h:\w\$ '
#PS1='\n\d \t\n\u@${debian_chroot:+($debian_chroot)} \h (\!)\n\w$(parse_git_branch)\$ '
export PS1='\n\e[31;40m\d \t\e[0m\n\e[32;40m\u@\h (\!)\e[0m\n\w$(parse_git_branch)\$ '


# Print some lines
echo
echo
echo
echo
echo
echo
echo
echo
echo
echo
echo
echo
echo
echo
echo
lt --group-directories-first
