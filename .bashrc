# Don't do shit if not connected to a terminal
[ -t 0 ] || return

# Truisms
export PATH="$HOME/bin:$PATH"
export LANG=en_US.UTF-8
export EDITOR=vim

# Record
if which ttyrec && [ ! "$TTYREC" ]; then
    find /var/log/shells/ -maxdepth 1 -type f -mtime +60 -regex ".*/*-$USER" -delete
    TTYREC=$$ ttyrec "/var/log/shells/$(date +%F_%H%M%S)-$USER" && exit $?
fi

# Create a new group for this session
if grep /sys/fs/cgroup/cpu/user <(mount); then
    mkdir -pm 0700 /sys/fs/cgroup/cpu/user/$$
    echo $$ > /sys/fs/cgroup/cpu/user/$$/tasks
fi

# Multiplex
if [ ! "$TMUX" ]; then
    [ "$SSH_CONNECTION" ] && tmux -2 attach || tmux -2 new
    [ ! -e "$HOME/dontquit" ] && exit 0
fi

# Transfer X credentials in SSH sessions
[ localhost:10.0 = "$DISPLAY" ] && export XAUTHORITY=~i/.Xauthority

# Spawn / reuse ssh agent
if which ssh-agent && [ -d "$HOME/.ssh" ]; then
    sshenv="$HOME/.ssh/env"
    usesshagent() {
        if [ -f "$sshenv" ]; then
            . "$sshenv"
            pgrep ssh-agent | grep "^$SSH_AGENT_PID$" > /dev/null && return 0
        fi
        ssh-agent > "$sshenv"
        usesshagent
    }
    usesshagent
    ssh-add
fi

# Shell options
shopt -s autocd
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
stty -ixon

# History
HISTFILESIZE=
HISTSIZE=
HISTCONTROL=ignoreboth
HISTTIMEFORMAT='%F %T '
HISTIGNORE='&:exit'
PROMPT_COMMAND='history -a; history -n'

# Filesystem traversal
cd() {
    [ "$1" = '--' ] && shift
    dest="${1:-$HOME}"
    [ "$(pwd)" != "$(readlink -f "$dest")" ] && pushd "$dest";
}
..() {
    newdir="${PWD/\/$1\/*/}/$1"
    [ -d "$newdir" ] && cd "$newdir" && return 0
    [ $1 -ge 0 ] 2> /dev/null && x=$1 || x=1
    for (( i = 0; i < $x; i++ )); do cd ..; done;
}
mkcd() { mkdir -p "$*"; cd "$*"; }
dud() { du -hxd1 "${1:-.}" | sort -h; }
alias b='popd'

xs() {
    [ -d "$@" ] 2>/dev/null && pushd "$@" && return
    dirs=()
    while read dir ;do
        dirs+=("$dir")
    done < <(find -type d -iname "*${@%% }*" 2>/dev/null)
    case ${#dirs[@]} in
        0)
            return 1
            ;;
        1)
            pushd "${dirs[@]}"
            ;;
        *)
            select dir in "${dirs[@]}" ; do
                pushd "$dir"
                break
            done
            ;;
    esac
}

fasd_cache="$HOME/.fasd-init-bash"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
    fasd --init bash-hook bash-ccomp bash-ccomp-install >| "$fasd_cache"
fi
. "$fasd_cache"
fasd_cd() { [ $# -gt 1 ] && cd "$(fasd -e echo "$@")" || fasd "$@"; }
alias j='fasd_cd -d'
alias f='fasd -f'

# Completion
complete -W "$(echo $(grep -a '^ssh ' "$HOME/.bash_history" | sort -u | sed 's/^ssh //'))" ssh

_w(){
    COMPREPLY=($(grep -h "^${COMP_WORDS[COMP_CWORD]}" /usr/share/dict/words))
    return 0
}
complete -F _w w

_..() {
    local word=${COMP_WORDS[COMP_CWORD]}
    local list=$(pwd | cut -c 2- | sed -e 's#/[^/]*$##g' -e 's/\([ ()]\)/\\\\\1/g')
    IFS=/
    list=$(compgen -W "$list" -- "$word")
    IFS=$'\n'
    COMPREPLY=($list)
    return 0
}
complete -F _.. ..

_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 ) )
}
complete -o default -F _pip_completion pip

alias v=v
_fasd_bash_hook_cmd_complete j v mp

export FZF_DEFAULT_OPTS='-e -m --bind=ctrl-u:page-up,ctrl-d:page-down,alt-o:print-query'
export FZF_DEFAULT_COMMAND='ag -g ""'
[ -f ~/.fzf.bash ] && . ~/.fzf.bash

# ls
LS_OPTIONS='-lh --color=auto --quoting-style=shell'
alias l="ls $LS_OPTIONS"
alias ll="ls $LS_OPTIONS -A"
alias lt="ls $LS_OPTIONS -tr"
alias ld="ls $LS_OPTIONS -Ad */"
alias lss="ls $LS_OPTIONS -Sr"

# grep
alias gp='grep --color=auto -i'
lg() { ll "${2:-.}" | gp "$1"; }
fgg() { find "${2:-.}" | gp "$1"; }
pg() { gp "$@" <<< "$(ps -eF --sort=start_time)"; }

# vim
vv() { [ -z $1 ] && vim -c "normal '0" || vim -p *$**; }
vg() { vim -p $(grep -l "$*" *); }
vz() {
    bind '"\C-z":" \C-u fg\C-j"'
    trap "stty susp '^z'" DEBUG
    PROMPT_COMMAND="$PROMPT_COMMAND; stty susp ''"
    [ "$1" ] && vi "$@"
}

# Web
alias webshare='python -m "SimpleHTTPServer"'
alias wclip='curl -F "sprunge=<-" http://sprunge.us | tee >(xsel -i)'
exp() { curl -Gs "https://www.mankier.com/api/explain/?cols="$(tput cols) --data-urlencode "q=$*"; }
wf() { curl "http://api.wolframalpha.com/v1/query?input=$*&appid=LAWJG2-J2GVW6WV9Q" 2>/dev/null | grep plaintext | sed -n 2,4p | cut -d '>' -f2 | cut -d '<' -f1; }
wff() { while read r; do wf $r; done; }

# Media
alias d0='DISPLAY=":0.0"'
alias d1='DISPLAY="localhost:10.0"'
alias feh='feh -ZF'
alias mpv='mpv --volume-max=1000'
alias mpt='mpv http://localhost:8888/'
alias mpl='mpv -lavdopts lowres=1:fast:skiploopfilter=all'
alias mpy='mpv -vf yadif'
mplen() { wf `mpv -vo dummy -ao dummy -identify "$1" 2>/dev/null | grep ID_LENGTH | cut -c 11-` seconds to minutes; }

# General aliases and functions
log() { $@ 2>&1 | tee log.txt; }
til() { sleep $(( $(date -d "$*" +%s) - $(date +%s) )); }
sume() { [ "$EUID" -ne 0 ] && sudo -E su -p && [ ! -e "$HOME/dontquit" ] && exit; }
alias x='TMUX="" TTYREC="" startx &'
alias gl='git log --graph --all --decorate --oneline'
alias gll='git log --graph --all --decorate --oneline --simplify-by-decoration'

# Steal all tmux windows into current session
muxjoin() {
    for win in $(tmux list-windows -aF "#{session_name}:#{window_index}"); do
        [ $win = $(tmux display-message -p '#{session_name}:#{window_index}') ] && continue
        tmux move-window -ds "$win"
    done
}

# Break a tmux window to a new terminal window
muxbreak() {
    TMUX='' urxvtcd -e dash -c "tmux new-session \\; move-window -ds $1 \\; swap-window -t2 \\; kill-window";
}

# Split current tmux session to multiple terminal windows
muxsplit() {
    for win in $(tmux list-windows -F "#{session_name}:#{window_index}"); do
        [ $win = $(tmux display-message -p '#{session_name}:#{window_index}') ] && continue
        muxbreak $win
    done
}

alias muxheist='muxjoin && muxsplit'

# Easy view
which dircolors && eval "`dircolors`"
which lesspipe && eval "`lesspipe`"
alias pyg='pygmentize -g -f terminal256 -O style=monokai'
alias pygl='LESSOPEN="| pygmentize -g -f terminal256 -O style=monokai %s" less'
export LESS=' -MR '
export LESS_TERMCAP_us=$'\e[32m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'
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
hasjobs(){
    pids=($(jobs -p))
    [ "${#pids[@]}" -gt 1 ] && echo -e "\e[30;41m!\e[0m"
}
retcode(){
    orig="$?"
    [ 0 != "$orig" ] && echo -e "\e[30;41m$orig\e[0m"
}
# Single line version
PS1='$(retcode)\e[31;40m\u@\h:\e[0m\e[32;40m\W$(gitstat)$(hasjobs)\e[0m\$ '
PS1='\n\e[31;40m\\\D{%d %b %y - %H:%M:%S}/\e[0m\n$(retcode)\n\e[31;40m\u@\h(\!):\e[0m\e[32;40m\w$(gitstat)$(hasjobs)\e[0m\n\$ '

lt --group-directories-first
