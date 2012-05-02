# Don't do shit if not connected to a terminal
[ -t 0 ] || return

# Multiplex
[ ! "$TMUX" ] && tmux -2 new-session && [ ! -e /tmp/dontquit ] && exit 0

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
setopt autocontinue autoresume noflowcontrol
setopt clobber extendedglob nocaseglob
REPORTTIME=10
PAGER=pager.sh
READNULLCMD=$PAGER

# Keys
bindkey -e
bindkey " " magic-space
bindkey "^p" history-beginning-search-backward
bindkey "^n" history-beginning-search-forward
bindkey "^q" push-line-or-edit
autoload -Uz edit-command-line && zle -N edit-command-line && bindkey "^x^e" edit-command-line

# Ugly kludge to make sure PREFIX is set after the longest unambiguous completion, so I can mark the spot with list-colors
unambigandmenu() { zle expand-or-complete; zle magic-space; zle backward-delete-char; zle expand-or-complete; } && zle -N unambigandmenu && bindkey "^i" unambigandmenu

# History
HISTFILE=$HOME/.zsh_history
HISTSIZE=1000
SAVEHIST=999999999
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
            read -q r
            [ "$r" = 'y' ] && zle && print -s -- $BUFFER && echo "Saved"
        fi
    fi
    return $(( 128 + $1 ))
}

# Completion.
autoload -Uz compinit && compinit && {
    setopt listpacked nolistambiguous
    zstyle ':completion:*' use-cache 1
    zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
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
    hosts=($(cut -d ';' -f 2 "$HOME/.zsh_history" | grep '^ssh ' | cut -c 4- | sort -u | tr "\n" " "))
    zstyle ':completion:*:(ssh|scp|sshfs):*' hosts $hosts

   # Highlight non-ambiguous part of completion in menu
   zstyle -e ':completion:*' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==31=32}:${(s.:.)LS_COLORS}")'
}

# Filesystem traversal
export PATH="$HOME/bin:$PATH"
#export CDPATH='.:~'
setopt autocd autopushd pushdignoredups
..() { if [ $1 -ge 0 2> /dev/null ]; then x=$1; else x=1; fi; for (( i = 0; i < $x; i++ )); do cd ..; done; }
mkcd() { mkdir -p "$*"; cd "$*"; }
alias b='popd'
alias m='mntnir.sh'
alias d='trash'
alias dud='du --max-depth=1 -h | sort -h'
eval "$(fasd --init zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install)"
fasd_cd() { [ $# -gt 1 ] && cd "$(fasd -e echo "$@")" || fasd "$@"; }
alias j='fasd_cd -d'

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
v() { if [ -z $1 ]; then vim -c "normal '0"; else vim -p *$1*; fi }
vg() { vim -p $(grep -l "$*" *); }
alias vv='fasd -e vim'
alias vf='find && vim -c "CtrlP"'
alias vs='vim -c "set spell | set buftype=nofile"'

# Media
alias d0='DISPLAY=":0.0"'
alias d1='DISPLAY="localhost:10.0"'
alias mm='fasd -fe mplayer'
alias mp='mplayer'
alias mpl='mplayer -lavdopts lowres=1:fast:skiploopfilter=all'
alias mpy='mplayer -vf yadif'
alias feh='feh -ZF'
mplen() { wf `mplayer -vo dummy -ao dummy -identify "$1" 2>/dev/null | grep ID_LENGTH | cut -c 11-` seconds to minutes; }

# Web
alias webshare='python -c "import SimpleHTTPServer;SimpleHTTPServer.test()"'
alias wclip='curl -F "sprunge=<-" http://sprunge.us | xclip -f'
wclipfile() { curl -F "sprunge=@$1" http://sprunge.us | xclip -f; }
t() {
    [ "$(pgrep deluged)" ] || deluged
    if [ "$1" ]; then
        if [ 'q' = "$1" ]; then killall deluged
        elif [ 'i' = "$1" ]; then shift && deluge-console "info $@ --sort-reverse=state"
        elif [ 'f' = "$1" ]; then shift && watch -n 0.5 "deluge-console 'info $@ --sort-reverse=state' | tail -n 6"
        else deluge-console add $@
        fi
    else
        deluge-console "info --sort-reverse=state"
    fi
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
            s ) query="${query}duckduckgo.com/?q=$*" ;;
            g ) query="${query}google.com/search?q=$*" ;;
            l ) query="${query}google.com/search?q=$*&btnI=" ;;
            w ) query="${query}en.wikipedia.org/w/index.php?title=Special:Search&search=$*&go=Go" ;;
            d ) query="${query}dictionary.reference.com/browse/$*" ;;
            m )
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
wff() { while read r; do wf $r; done; }

# General aliases and functions
alias x='TMUX="" startx &!'
log() { $@ 2>&1 | tee log.txt; }

# Colors
reset='[0m'
red='[00;31m'
green='[00;32m'
blue='[00;34m'
eval $(dircolors -b)
export LESS='-MR'
export LESS_TERMCAP_us=$green
export LESS_TERMCAP_ue=$reset
export LESS_TERMCAP_md=$red
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
