# Don't do shit if not connected to a terminal
[ -t 0 ] || return

# Truisms
export PATH="$HOME/bin:$PATH"
export LANG=C.UTF-8

# Multiplex
if [ "$SSH_CONNECTION" ] && [ 0 -ne "$UID" ]; then
    su -c 'tmux list-ses' && su || su -
    exit 0
elif [ ! "$TMUX" ]; then
    ([ "$SSH_CONNECTION" ] && tmux -2 attach || tmux -2 new) &&
    [ ! -e /tmp/dontquit ] && exit 0
fi

# Make nice
renice -n -10 -p "$$" > /dev/null
ionice -c 2 -n 0 -p "$$" > /dev/null

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
HISTFILESIZE=999999
HISTSIZE=999999
HISTCONTROL=erasedups,ignoreboth
HISTTIMEFORMAT='%F %T '
HISTIGNORE='&:exit'
PROMPT_COMMAND='history -a; history -n'

# Filesystem traversal
cd() { [ -z "$1" ] && set -- ~; [ "$(pwd)" != "$(readlink -f "$1")" ] && pushd "$1"; }
..() { if [ $1 -ge 0 2> /dev/null ]; then x=$1; else x=1; fi; for (( i = 0; i < $x; i++ )); do cd ..; done; }
mkcd() { mkdir -p "$*"; cd "$*"; }
alias b='popd'
alias d='trash-put'
alias dud='du -hxd 1 | sort -h'

fasd_cache="$HOME/.fasd-init-bash"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
    fasd --init bash-hook bash-ccomp bash-ccomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
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
complete -W "$(echo $(grep -a '^ssh ' "$HOME/.bash_history" | sort -u | sed 's/^ssh //'))" ssh
_fasd_bash_hook_cmd_complete j v mpp

_w(){
    COMPREPLY=($(grep -h "^${COMP_WORDS[COMP_CWORD]}" /usr/share/dict/words))
    return 0
}
complete -F _w w

# ls
LS_OPTIONS='-lh --color=auto'
alias l="ls $LS_OPTIONS"
alias ll="ls $LS_OPTIONS -A"
alias lt="ls $LS_OPTIONS -tr"
alias ld="ls $LS_OPTIONS -A -d */"
alias lss="ls $LS_OPTIONS -Sr"

# grep
export GREP_OPTIONS='-i --color=auto'
alias lg='ll | grep'
alias fgg='find | grep'
alias pg='ps -eo start_time,pid,command --sort=start_time | grep -v grep | grep'

# vim
alias v='fasd -e vim -b viminfo'
vv() { [ -z $1 ] && vim -c "normal '0" || vim -p *$**; }
vg() { vim -p $(grep -l "$*" *); }
alias vf='find && vim -c "CtrlP"'
alias vs='vim -c "set spell | set buftype=nofile"'

# Media
alias d0='DISPLAY=":0.0"'
alias d1='DISPLAY="localhost:10.0"'
alias mpp='mpv'
alias mpl='mpv -lavdopts lowres=1:fast:skiploopfilter=all'
alias mpy='mpv -vf yadif'
alias feh='feh -ZF'
mplen() { wf `mpv -vo dummy -ao dummy -identify "$1" 2>/dev/null | grep ID_LENGTH | cut -c 11-` seconds to minutes; }

# Web
alias webshare='python -c "import SimpleHTTPServer;SimpleHTTPServer.test()"'
alias wclip='curl -F "sprunge=<-" http://sprunge.us | xclip -f'
wf() { w3m "http://m.wolframalpha.com/input/?i=$(perl -MURI::Escape -e "print uri_escape(\"$*\");")" -dump 2>/dev/null | grep -A 2 'Result:' | tail -n 1; }
wf() { wget -O - "http://api.wolframalpha.com/v1/query?input=$*&appid=LAWJG2-J2GVW6WV9Q" 2>/dev/null | grep plaintext | sed -n 2,4p | cut -d '>' -f2 | cut -d '<' -f1; }
wff() { while read r; do wf $r; done; }
trans() {
    local from="$1"
    local to="$2"
    shift 2
    q="$*"
    q=${q// /+}
    curl -s -A "Mozilla/5.0" "http://translate.google.com.br/translate_a/t?client=t&text=$q&sl=$from&tl=$to" | awk -F'"' '{print $2}'
}
say() {
    local lang="$1"
    shift
    q="$*"
    q=${q// /+}
    mpv "http://translate.google.com/translate_tts?ie=UTF-8&tl=$lang&q=$q"
}

# General aliases and functions
alias x='TMUX="" startx &'
log() { $@ 2>&1 | tee log.txt; }
til() { sleep $(( $(date -d "$*" +%s) - $(date +%s) )); }

# Steal all tmux windows into current session
muxjoin() {
    [ ! "$TMUX" ] && echo 'tmux not running' 1>&2 && exit 1
    tmux set status on
    for win in $(tmux list-windows -a | cut -d : -f 1-2); do
        tmux move-window -d -s "$win"
    done
}

# Split current tmux session to multiple X terminals
muxsplit() {
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
LESS='-MR'
LESS_TERMCAP_us=$'\e[32m'
LESS_TERMCAP_ue=$'\e[0m'
LESS_TERMCAP_md=$'\e[1;31m'
LESS_TERMCAP_me=$'\e[0m'
export MANPAGER='sh -c "col -b | vim -c \"set buftype=nofile ft=man ts=8 nolist nonumber norelativenumber\" -c \"map q <Esc>:qa!<CR>\" -c \"normal M\" -"'

# Preprompt
PROMPT_COMMAND="$PROMPT_COMMAND; t=yes"
preex () {
    if [ "$t" ]; then
        unset t;
        echo -e "\n\e[31;40m/$(date '+%d %b %y - %H:%M:%S')\\ \e[0m"
    fi
}
trap 'preex' DEBUG

# Prompt
gitstat() {
    branch=$(git symbolic-ref HEAD 2> /dev/null) || exit 0
    branch=${branch:11}
    dirty=$(git status --porcelain 2> /dev/null | grep -v '^??' | wc -l)
    ahead=$(git log origin/$branch..HEAD 2> /dev/null | grep '^commit' | wc -l)

    echo -n "($branch"
    [ 0 = "$dirty" ] || echo -ne "\e[31;40m $dirty\e[0m"
    [ 0 = "$ahead" ] || echo -ne "\e[32;40m $ahead\e[0m"
    echo -n ')'
}
retcode(){
    orig="$?"
    [ 0 != "$orig" ] && echo -e "\e[30;41m$orig\e[0m"
}
PS1='\n\e[31;40m\\\D{%d %b %y - %H:%M:%S}/\e[0m\n$(retcode)\n\e[31;40m\u@\h(\!):\e[0m\e[32;40m\w$(gitstat)\e[0m\n\$ '

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
ls -lhtr --color=auto --group-directories-first
