# Don't do shit if not connected to a terminal
[ -t 0 ] || return

# Multiplex
[ ! "$TMUX" ] &&
    ([ "$SSH_CONNECTION" ] && tmux -2 attach \; set status on || tmux -2 new) &&
    [ ! -e /tmp/dontquit ] && exit 0

# Turn status line for remote connections
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

export TERM=screen

# Make nice
renice -n -10 -p "$$" > /dev/null
ionice -c 2 -n 0 -p "$$" > /dev/null

# Create a new group for this session
mkdir -pm 0700 /sys/fs/cgroup/cpu/user/$$
echo $$ > /sys/fs/cgroup/cpu/user/$$/tasks

# Shell options
setopt autocontinue autoresume noflowcontrol
setopt clobber extendedglob nocaseglob
REPORTTIME=10
PAGER=pager.sh
READNULLCMD=$PAGER

# Keys
export WORDCHARS=''
export KEYTIMEOUT=100
bindkey -e
bindkey "^p" history-beginning-search-backward
bindkey "^n" history-beginning-search-forward
bindkey "^q" push-line-or-edit
bindkey "^u" vi-kill-line
bindkey -s '\eu' '^qcd ..^M'
bindkey -s '|p' "| $PAGER"
bindkey -s '|g' '| grep '
bindkey -s '|w' '| wc '
bindkey -s '|v' '| vi -c "set buftype=nofile" - '
bindkey -s '|c' '| cut -d " " -f '

autoload -Uz edit-command-line && zle -N edit-command-line && bindkey "^x^e" edit-command-line

# Space at the start of a command line starts history search.
# Double space tries to completes what is already typed.
# Otherwise just insert a magic space.
space-check() {
    if [ "$MC_TMPDIR" ]; then
        zle magic-space
    elif [ ! "$LBUFFER" ]; then
        zle history-incremental-search-backward ''
    elif [ ' ' = "${LBUFFER[-1]}" ]; then
        zle backward-delete-char
        zle history-beginning-search-backward
    else
        zle magic-space
    fi
} && zle -N space-check && bindkey ' ' space-check
bindkey -M isearch ' ' history-incremental-search-backward
bindkey -M isearch '^x ' self-insert

# C-j kills till end of line before accepting
kill-accept() { zle kill-line; zle accept-line } && zle -N kill-accept && bindkey '^j' kill-accept

# Kludge to make sure PREFIX is set after the longest unambiguous completion, so I can mark the spot with list-colors
unambigandmenu() { zle expand-or-complete; zle magic-space; zle backward-delete-char; zle expand-or-complete; } && zle -N unambigandmenu && bindkey "^i" unambigandmenu

# History
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=999999999
export SAVEHIST=999999999
setopt histexpiredupsfirst
setopt extendedhistory sharehistory histverify
setopt histignoredups histignorespace histfindnodups

# Save cancelled commands to clipboard, or - conditionally - to history
TRAPINT () {
    if [ "$BUFFER" ]; then
        if [ "$DISPLAY" ]; then
            echo -n $BUFFER | xclip
        else
            echo "\nSave '$BUFFER'? "
            read -q && zle && print -s -- $BUFFER && echo "Saved"
        fi
    fi
    return $(( 128 + $1 ))
}

# Completion.
autoload -Uz compinit && compinit && {
    setopt listpacked nolistambiguous
    zstyle ':completion:*' use-cache true
    zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'r:[._-]=*'
    zstyle ':completion:*' ignore-parents parent pwd ..
    zstyle ':completion:*' menu auto select
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*' format '%B%F{cyan}%d%f%b'
    zstyle ':completion:*' select-prompt '%B%F{cyan}%p %l %m %f%b'
    zstyle ':completion:*' auto-description ': %d'
    zstyle ':completion:*' show-completer true

    # Pretty style for kill
    zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

    # Get hosts from history
    zstyle -e ':completion:*' hosts 'reply=($(grep "^.\{15\}ssh " "$HOME/.zsh_history" | cut -c 20-))'

    # Highlight non-ambiguous part of completion in menu
    zstyle -e ':completion:*' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==34=37}:${(s.:.)LS_COLORS}")'
}

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

compctl -K xsfind -M 'r:|[a-z]=**' xs

# Filesystem traversal
export PATH="$HOME/bin:$PATH"
#export CDPATH='.:~'
setopt autocd autopushd pushdignoredups
..() { if [ $1 -ge 0 2> /dev/null ]; then x=$1; else x=1; fi; for (( i = 0; i < $x; i++ )); do cd ..; done; }
mkcd() { mkdir -p "$*"; cd "$*"; }
alias b='popd'
alias m='mntnir.sh'
alias d='trash-put'
alias dud='du --max-depth=1 -h | sort -h'
eval "$(fasd --init zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install)"
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
    [ 'q' = "$1" ] && return $(pkill -x deluged)
    if [ ! "$(pgrep -x deluged)" ]; then
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
alias x='TMUX="" startx &!'
log() { $@ 2>&1 | tee log.txt; }

# Colors
reset='[0m'
red='[00;31m'
green='[00;32m'
blue='[00;36m'
eval $(dircolors -b)
export LESS='-MR'
export LESS_TERMCAP_us=$green
export LESS_TERMCAP_ue=$reset
export LESS_TERMCAP_md=$blue
export LESS_TERMCAP_me=$reset
source "$HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Extended prompt
PROMPT="%F{green}(%!)%#%f "

precmd() {
    err=$?
    print -P "%F{red}\\\%D{%g-%m-%d %H:%M:%S}/%f"
    [ "$err" -eq 0 ] || print -P "%K{red}%F{black}$err%f%k"
    print -nP "\n%F{red}%n@%M:%F{green}%d%f"

    if [ "$isgit" ]; then
        branch=${"$(git symbolic-ref HEAD 2> /dev/null)":11}
        print -nP "%F{cyan}($branch"
        dirty=$(git status --porcelain 2> /dev/null | grep -v '^??' | wc -l)
        if (( $dirty > 0)); then print -nP " %F{red}$dirty%f"; fi
        ahead=$(git log origin/$branch..HEAD 2> /dev/null | grep '^commit' | wc -l)
        if (( $ahead > 0)); then print -nP " %F{green}$ahead%f"; fi
        print -nP ")%f"
    fi
    echo
}

preexec() {
    print -P "%F{green}/%D{%g-%m-%d %H:%M:%S}\\\\%f"
}

chpwd() {
    isgit=$(git symbolic-ref HEAD 2> /dev/null)
}

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
