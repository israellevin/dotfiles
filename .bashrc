# Don't do shit if not connected to a terminal
[ -t 0 ] || return

# Multiplex
if [ ! "$TMUX" ]; then
    if [ "$SSH_CONNECTION" ]; then
        if [ "$DISPLAY" ]; then
            export DISPLAY=localhost:10.0
        fi
        tmux -2 attach
    else
        tmux -2 new
        [ -e /tmp/dontquit ] || exit 0
    fi
fi

# Make nice
renice -n -10 -p "$$"

# Create a new cgroup for this session
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

# History
export HISTFILESIZE=999999
export HISTSIZE=999999
export HISTCONTROL=erasedups,ignoreboth
export HISTTIMEFORMAT='%F %T '
export HISTIGNORE='&:exit'
export PROMPT_COMMAND='history -a; history -n'

# Filesystem traversal
export PATH="$HOME/bin:$PATH"
cd() { [ -z "$1" ] && set -- ~; [ "$(pwd)" != "$(readlink -f "$1")" ] && pushd "$1"; }
..() { if [ $1 -ge 0 2> /dev/null ]; then x=$1; else x=1; fi; for (( i = 0; i < $x; i++ )); do cd ..; done; }
mkcd() { mkdir -p "$*"; cd "$*"; }
alias b='popd'
alias d='trash-put'
alias dud='du -hxd 1 | sort -h'
eval "$(fasd --init auto)"
fasd_cd() { [ $# -gt 1 ] && cd "$(fasd -e echo "$@")" || fasd "$@"; }
alias j='fasd_cd -d'
alias f='fasd -f'

xsfind() {
    needle="$@"
    reply=()
    while read line ;do
        reply+=("${line:2}")
    done < <(find ./ -type d -iname "*${needle%% }*" 2>/dev/null)
}

xs() {
    [ -d "$@" ] 2>/dev/null && cd "$@" && return
    xsfind $@
    case ${#reply[@]} in
        0)
            false
            ;;
        1)
            pushd "${reply[@]}"
            ;;
        *)
            select dir in "${reply[@]}" ; do
                pushd "$dir"
                break
            done
            ;;
    esac
}

# Completion
source /etc/bash_completion
complete -W "$(echo $(grep '^ssh ' .bash_history | sort -u | sed 's/^ssh //'))" ssh
_fasd_bash_hook_cmd_complete j vv mm

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

# Colors
eval "`dircolors`"
export LESS='-MR'
export LESS_TERMCAP_us=$'\e[32m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'
export MANPAGER='sh -c "col -b | vim -c \"set buftype=nofile ft=man ts=8 nolist\" -c \"map q <Esc>:qa!<CR>\" -c \"normal M\" -"'
export TERM=screen-256color

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
