# Don't do shit if not connected to a terminal
[ -t 0 ] || return

# Truisms
export PATH="$HOME/bin:$PATH"
export LANG=en_US.UTF-8
export EDITOR=vim
export BROWSER=w3m
export GDK_SCALE=1

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
alias d='fasd -d'
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
    COMPREPLY=($(grep -h "^${COMP_WORDS[COMP_CWORD]}" /usr/share/dict/[ab]*))
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
type ag > /dev/null || alias ag='grep --color=auto -i'
lg(){ ll "${2:-.}" | ag "$1"; }
fgg(){ find "${2:-.}" | ag "$1"; }
pg(){ ag "$@" <<< "$(ps -eF --forest | sort)"; }

# vim
vj(){ vim -c'set bt=nofile| set fdm=indent| set fdl=5| set ft=json'; }
vv(){ [ -z $1 ] && vim -c "normal '0" || vim -p *$**; } # Open last file or all filenames matching argument.
vg(){ vim -p $(ag -l "$*" *); } # Open all files containing argument.
vz(){ # Toggle vim with C-z.
    bind '"\C-z":" \C-u fg\C-j"'
    trap "stty susp '^z'" DEBUG
    PROMPT_COMMAND="$PROMPT_COMMAND; stty susp ''"
    [ "$1" ] && vi "$@"
}
vd(){ # Recursive vimdiff.
    diff -rq "$1" "$2" | sed -n 's/^Files \(.*\) and \(.*\) differ$/"\1" "\2"/p' | xargs -n2 vimdiff
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
connect(){
    [ "$2" ] && wpa_supplicant -i wlan0 -c <(wpa_passphrase "$1" "$2") \
    || while :; do iw dev wlan0 link | ag not\ connected && date && iw dev wlan0 connect "$1"; sleep 10; done
}

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
from_json() { node -pe "JSON.parse(require('fs').readFileSync(0, 'utf-8'))$1"; }
alias x='TMUX="" TTYREC="" startx &'
gitformat="%s %C(dim)%C(cyan)%ah %C(green)%al %C(magenta)%h%C(auto)%d"
alias glg="git log --graph --abbrev-commit --pretty=format:'$gitformat'"
alias gll="glg --exclude=refs/remotes/** --all --decorate-refs=refs/heads/"
alias gl="glg --all"
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
# Note the surrounding $'\001' and $'\002'  which tell readline the escape sequence has zero length.
# Bash documentation recommends using escaped square brackets, but these fail on command substitution.
RED=$'\001'"$(tput setaf 1)"$'\002'
GREEN=$'\001'"$(tput setaf 2)"$'\002'
YELLOW=$'\001'"$(tput setaf 3)"$'\002'
BLUE=$'\001'"$(tput setaf 4)"$'\002'
MAGENTA=$'\001'"$(tput setaf 5)"$'\002'
CYAN=$'\001'"$(tput setaf 6)"$'\002'
REVERSE=$'\001'"$(tput rev)"$'\002'
RESET=$'\001'"$(tput sgr0)"$'\002'

# Easy view
type dircolors > /dev/null && eval "`dircolors`"
type lesspipe > /dev/null && eval "`lesspipe`"
alias pyg='pygmentize -g -f terminal256 -O style=monokai'
alias pygl='LESSOPEN="| pygmentize -g -f terminal256 -O style=monokai %s" less'
export LESS=' -MRSXF '
export LESS_TERMCAP_us=$GREEN
export LESS_TERMCAP_ue=$RESET
export LESS_TERMCAP_md=$RED
export LESS_TERMCAP_me=$RESET
if type nvim > /dev/null; then
    export MANPAGER='nvim +Man!'
else
    export MANPAGER='vim -M +MANPAGER -c "set nonumber" -'
fi

# Prompt
gitstat(){
    orig_retcode=$?
    branch=$(git symbolic-ref HEAD 2> /dev/null) || return $orig_retcode
    branch=${branch:11}
    dirty=$(git status --porcelain 2> /dev/null | grep -v '^??' | wc -l)
    ahead=$(git log origin/$branch..HEAD 2> /dev/null | grep '^commit' | wc -l)
    echo -n "($branch"
    [ 0 = "$dirty" ] || echo -n " $RED$dirty$RESET"
    [ 0 = "$ahead" ] || echo -n " $GREEN$ahead$RESET"
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
PS1="$RED$REVERSE\$(retcode)$RESET$RED\u@\$(hostorchrootname):$RESET"
PS1+="$GREEN\W$RESET$YELLOW\$(gitstat)$RESET$CYAN$REVERSE\$(hasjobs)$RESET\$ "

# Multiline version
PS0="$BLUE/\D{%d %b %y - %H:%M:%S}\\$RESET\n"
PS1="$BLUE\\\\\D{%d %b %y - %H:%M:%S}/$RESET\n"
PS1+="$RED\u@\$(hostorchrootname)(\!):$RESET$GREEN\w$RESET$YELLOW\$(gitstat)$RESET\n"
PS1+="$RED$REVERSE\$(retcode)$RESET$CYAN$REVERSE\$(hasjobs)$RESET\$ "

lt
