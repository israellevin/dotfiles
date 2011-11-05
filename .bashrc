# ~/.bashrc: executed by bash(1) for non-login shells.

# Don't do shit if not connected to a terminal
[ -t 0 ] || return

# Multiplex
[ ! "$TMUX" ] && tmux new-session && [ ! -e /tmp/dontquit ] && exit 0

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

# Create a new group for this session
#mkdir -pm 0700 /sys/fs/cgroup/cpu/user/$$
#echo $$ > /sys/fs/cgroup/cpu/user/$$/tasks

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

# Directory traversing and file management
export PATH="~/bin:$PATH"
export CDPATH='.:~'
cd() { if [ -z "$1" ]; then pushd ~; else pushd "$1"; fi; }
..() { if [ $1 -ge 0 2> /dev/null ]; then x=$1; else x=1; fi; for (( i = 0; i < $x; i++ )); do cd ..; done; }
mkcd() { mkdir -p "$*"; cd "$*"; }
alias b='popd'
alias m='~/bin/mntnir.sh'
alias d='trash'
alias dud='du --max-depth=1 -h | sort -h'
source ~/bin/autojump.bash

# ls
export LS_OPTIONS='-lh'
alias l='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -A'
alias lt='ls $LS_OPTIONS -tr'
alias ld='ls $LS_OPTIONS -A -d */'
alias lss='ls $LS_OPTIONS -Sr'

# grep
export GREP_OPTIONS='-i'
alias xgrep='~/bin/xgrep.sh'
alias lg='ll | xgrep'
alias fgg='find | xgrep'
alias hgg='history | xgrep'
alias pg='ps -ef | xgrep'
skill() { kill $(pg $@ | head -n 1 | cut -d ' ' -f 2); }

# vim
v() { if [ -z $1 ]; then vim -c "normal '0"; else vim -p *$1*; fi }
vg() { vim -p $(grep -l "$*" *); }
alias vf='find && vim -c "FufCoverageFile"'
alias vs='vim -c "set spell | set buftype=nofile"'
alias les='/usr/share/vim/vimcurrent/macros/less.sh'

# Media
alias d0='DISPLAY=":0.0"'
alias d1='DISPLAY="localhost:10.0"'
alias mp='DISPLAY=":0.0" mplayer -fs -zoom'
alias mpl='DISPLAY=":0.0" mplayer -fs -zoom -lavdopts lowres=1:fast:skiploopfilter=all'
alias mpy='DISPLAY=":0.0" mplayer -fs -zoom -vf yadif'
alias feh='feh -ZF'
alias webcam='mplayer tv:// -tv device=/dev/video0'
mplen() { gc `mplayer -vo dummy -ao dummy -identify "$1" 2>/dev/null | grep ID_LENGTH | cut -c 11-` seconds in minutes; }

# Web
alias webshare='python -c "import SimpleHTTPServer;SimpleHTTPServer.test()"'
alias wclip='curl -F "sprunge=<-" http://sprunge.us | xclip -f'
wclipfile() { curl -F "sprunge=@$1" http://sprunge.us | xclip -f; }
gc() {
    q=$(perl -MURI::Escape -e "print uri_escape(\"$*\");")
    a=$(curl -A 'mozilla/4.0' "http://www.google.com/search?q=$q" | grep 'class=r')
    echo; echo "$a" | perl -pe 's/.*<h2 class=r.*?<b>(.*?)<\/b>.*/\1/;' ;}
wg() { w3m -dump "http://google.com/search?q=$*" | less ;}
ww() { w3m -dump "http://en.wikipedia.org/w/index.php?title=Special:Search&search=$*&go=Go" | less ;}
wd() { w3m -dump "http://dictionary.reference.com/browse/$*" | less ;}

# Prompt
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
PS1='u@\h:\w\$ '
export PS1='\n\d \t\n\u@${debian_chroot:+($debian_chroot)} \h (\!)\n\w$(parse_git_branch)\$ '

# Colors
#if [ ':0' == ${DISPLAY:0:2} ]; then
#if [ "$COLORTERM" ]; then
if [ 1 ]; then
    alias cgrep="grep $GREP_OPTIONS --color=always"
    alias crgrep="rgrep $GREP_OPTIONS --color=always"
    alias cls="ls $LS_OPTIONS --color=always"
    eval "`dircolors`"
    export PS1='\n\e[31;40m\d \t\e[0m\n\e[32;40m\u@\h (\!)\e[0m\n\w$(parse_git_branch)\$ '
    export LS_OPTIONS="$LS_OPTIONS --color=auto"
    export GREP_OPTIONS="$GREP_OPTIONS --color=auto"
    export LESS='-MR'
    export LESS_TERMCAP_us=$'\e[32m'
    export LESS_TERMCAP_ue=$'\e[0m'
    export LESS_TERMCAP_md=$'\e[1;31m'
    export LESS_TERMCAP_me=$'\e[0m'
fi

# General aliases and functions
alias startx='TMUX="" startx &'
alias dmenu='dmenu -i -l 20 -nb black -nf green -sb green -sf black -fn -*-terminus-*-*-*-*-24-*-*-*-*-*-*-*'
log() { $@ 2>&1 | tee log.txt; }

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

thesaurus() {
    define $1 moby-thes
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

[ -f /usr/share/dict/words ] &&\
_thesaurus(){
    COMPREPLY=( $( grep -h "^${COMP_WORDS[COMP_CWORD]}" /usr/share/dict/words ) )
    return 0
} && complete -F _thesaurus thesaurus

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
source /etc/bash_completion
