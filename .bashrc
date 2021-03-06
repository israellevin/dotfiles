# Don't do shit if not connected to a terminal
[ -t 0 ] || return

# Truisms
export PATH="$HOME/bin:$PATH"
export LANG=en_US.UTF-8
export EDITOR=vim
export BROWSER=w3m

# Multiplex
if [ ! "$TMUX" ]; then
    [ "$SSH_CONNECTION" ] && tmux -2 attach || tmux -2 new
    [ ! -e "$HOME/dontquit" ] && exit 0
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
alias b='popd'
cd(){
    [ "$1" = '--' ] && shift
    dest="${1:-$HOME}"
    [ "$(pwd)" != "$(readlink -f "$dest")" ] && pushd "$dest";
}
..(){
    newdir="${PWD/\/$1\/*/}/$1"
    [ -d "$newdir" ] && cd "$newdir" && return 0
    [ $1 -ge 0 ] 2> /dev/null && x=$1 || x=1
    for(( i = 0; i < $x; i++ )); do cd ..; done;
}
xs(){
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
mkcd(){ mkdir -p "$*"; cd "$*"; }
dud(){ du -hxd1 "${1:-.}" | sort -h; }

fasd_cache="$HOME/.fasd-init-bash"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
    fasd --init bash-hook bash-ccomp bash-ccomp-install >| "$fasd_cache"
fi
. "$fasd_cache"
fasd_cd(){ [ $# -gt 1 ] && cd "$(fasd -e echo "$@")" || fasd "$@"; }
alias j='fasd_cd -d'
alias f='fasd -f'
_fasd_bash_hook_cmd_complete j

# fzf
export FZF_DEFAULT_OPTS='-e -m --bind=ctrl-u:page-up,ctrl-d:page-down,alt-o:print-query,ctrl-o:replace-query'
export FZF_DEFAULT_COMMAND='ag -g ""'
export FZF_TMUX=1
[ -f ~/.fzf.bash ] && . ~/.fzf.bash

# Completion
. /etc/bash_completion
complete -W "$(grep -aPo '(?<=^ssh ).*$' "$HOME/.bash_history" | sort -u | sed 's/\(.*\)/"\1"/'
)" ssh

_w(){
    COMPREPLY=($(grep -h "^${COMP_WORDS[COMP_CWORD]}" /usr/share/dict/words))
    return 0
}
complete -F _w w

_..(){
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

# ls
LS_OPTIONS='-lh --color=auto --quoting-style=shell'
alias l="ls $LS_OPTIONS"
alias ll="ls $LS_OPTIONS -A"
alias lt="ls $LS_OPTIONS -tr"
alias ld="ls $LS_OPTIONS -Ad */"
alias lss="ls $LS_OPTIONS -Sr"

# grep
which ag || alias ag='grep --color=auto -i'
lg(){ ll "${2:-.}" | ag "$1"; }
fgg(){ find "${2:-.}" | ag "$1"; }
pg(){ ag "$@" <<< "$(ps -eF --forest --sort=start_time)"; }

# vim
vv(){ [ -z $1 ] && vim -c "normal '0" || vim -p *$**; } # Open last file or all filenames matching argument.
vg(){ vim -p $(ag -l "$*" *); } # Open all files containing argument.
vz(){ # Toggle vim with C-z.
    bind '"\C-z":" \C-u fg\C-j"'
    trap "stty susp '^z'" DEBUG
    PROMPT_COMMAND="$PROMPT_COMMAND; stty susp ''"
    [ "$1" ] && vi "$@"
}
vd(){ # Recursive vimdiff.
    if [ -f "$1" ] && [ -f "$2" ]; then
        vimdiff "$1" "$2"
        return
    fi
    diff -rq "$1" "$2" | sed -n 's/^Files \(.*\) and \(.*\) differ$/vimdiff "\1" "\2"/p' | while read cmd; do
        sh <<<$cmd
    done
}

# Web
alias webshare='python3 -m http.server'
alias wclip='curl -F "sprunge=<-" http://sprunge.us | tee >(xsel -i)'
exp(){ curl -Gs "https://www.mankier.com/api/explain/?cols="$(tput cols) --data-urlencode "q=$*"; }
wf(){
    echo -e "$(curl -s -d format=plaintext -d output=JSON -d appid=LAWJG2-J2GVW6WV9Q -d "input='$*'" \
        https://api.wolframalpha.com/v2/query | grep -Po '(?<="plaintext":")[^"]*')";
}
wff(){ while read r; do wf $r; done; }

# Media
alias d0='DISPLAY=":0.0"'
alias d1='DISPLAY="localhost:10.0"'
alias feh='feh -ZF'
alias mpv='mpv --volume-max=1000'
alias mpt='mpv http://localhost:8888/'
alias mpl='mpv -lavdopts lowres=1:fast:skiploopfilter=all'
alias mpy='mpv -vf yadif'
mplen(){ ffmpeg -i "$1" 2>&1 | ag duration; }

# General aliases and functions
log(){ $@ 2>&1 | tee log.txt; }
til(){ sleep $(( $(date -d "$*" +%s) - $(date +%s) )); }
sume(){ [ "$EUID" -ne 0 ] && sudo -E su -p; }
genpas(){ shuf -zern${1:-8} ':' ';' '<' '=' '>' '?' '@' '[' ']' '^' '_' '`' '{' '|' '}' '~' {0..9} {A..Z} {a..z} {a..z} {a..z}; echo; }
gsl() { git fetch; git checkout "$(git branch -r | fzf | sed -e 's/^[[:space:]]*//')"; }
gmb() { git merge-base "$(git branch --show-current)" "${1:-master}"; }
alias x='TMUX="" TTYREC="" startx &'
alias gl='git log --graph --all --decorate --oneline'
alias gll='git log --graph --all --decorate --oneline --simplify-by-decoration'
alias pyx="python -m trace --ignore-dir \$(python -c 'import os, sys; print(os.pathsep.join(sys.path[1:]))') -t"

# Steal all tmux windows into current session
muxjoin(){
    for win in $(tmux list-windows -aF "#{session_name}:#{window_index}"); do
        [ $win = $(tmux display-message -p '#{session_name}:#{window_index}') ] && continue
        tmux move-window -ds "$win"
    done
}

# Break a tmux window to a new terminal window
muxbreak(){
    TMUX='' urxvtcd -e dash -c "tmux new-session \\; move-window -ds $1 \\; swap-window -t2 \\; kill-window";
}

# Split current tmux session to multiple terminal windows
muxsplit(){
    for win in $(tmux list-windows -F "#{session_name}:#{window_index}"); do
        [ $win = $(tmux display-message -p '#{session_name}:#{window_index}') ] && continue
        muxbreak $win
    done
}

alias muxheist='muxjoin && muxsplit'

# Some escape sequences for colors.
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
REVERSE="$(tput rev)"
CLEAR="\e[m"

# Easy view
which dircolors && eval "`dircolors`"
which lesspipe && eval "`lesspipe`"
alias pyg='pygmentize -g -f terminal256 -O style=monokai'
alias pygl='LESSOPEN="| pygmentize -g -f terminal256 -O style=monokai %s" less'
export LESS=' -MR '
export LESS_TERMCAP_us=$GREEN
export LESS_TERMCAP_ue=$CLEAR
export LESS_TERMCAP_md=$RED
export LESS_TERMCAP_me=$CLEAR
export MANPAGER='sh -c "col -b | vim -c \"set buftype=nofile ft=man ts=8 nolist nonumber norelativenumber\" -c \"map q <Esc>:qa!<CR>\" -c \"normal M\" -"'


# Prompt
gitstat(){
    orig_retcode=$?
    branch=$(git symbolic-ref HEAD 2> /dev/null) || return $orig_retcode
    branch=${branch:11}
    dirty=$(git status --porcelain 2> /dev/null | grep -v '^??' | wc -l)
    ahead=$(git log origin/$branch..HEAD 2> /dev/null | grep '^commit' | wc -l)
    echo -n "($branch"
    [ 0 = "$dirty" ] || echo -ne "${RED} ${dirty}${CLEAR}"
    [ 0 = "$ahead" ] || echo -ne "${GREEN} ${ahead}${CLEAR}"
    echo -n ')'
    return $orig_retcode
}
hasjobs(){
    orig_retcode=$?
    pids=($(jobs -p))
    num_pids=${#pids[@]}
    let num_pids--
    [ $num_pids -gt 0 ] && echo $num_pids
    return $orig_retcode
}
retcode(){
    orig_retcode=$?
    [ 0 != "$orig_retcode" ] && echo $orig_retcode
    return $orig_retcode
}
hostorchrootname(){
    orig_retcode=$?
    ischroot && cat /etc/hostname || hostname
    return $orig_retcode
}

# Single line version
PS1="${RED}$REVERSE\$(retcode)${CLEAR}$RED\u@\$(hostorchrootname):$CLEAR"
PS1+="${GREEN}\W${CLEAR}$YELLOW\$(gitstat)${CLEAR}${CYAN}$REVERSE\$(hasjobs)$CLEAR\$ "

# Multiline version
PS0="$BLUE/\D{%d %b %y - %H:%M:%S}\\ $CLEAR\n"
PS1="$BLUE\\\\\D{%d %b %y - %H:%M:%S}/ $CLEAR\n"
PS1+="$RED\u@\$(hostorchrootname)(\!):${CLEAR}$GREEN\w${CLEAR}$YELLOW\$(gitstat)$CLEAR\n"
PS1+="\[${RED}$REVERSE\]\$(retcode)\[${CLEAR}${CYAN}$REVERSE\]\$(hasjobs)\[$CLEAR\]\$ "

lt
