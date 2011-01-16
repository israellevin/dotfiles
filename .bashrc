# ~/.bashrc: executed by bash(1) for non-login shells.

# Don't do shit if not connected to a terminal
[ -t 0 ] || return

# Multiplex
if [ -z $TMUX ]; then
    tmux new -d -s all
    if [ 0 -eq $? ]; then
        tmux set -t all status on
        tmux -q new \; linkw -t all \; kill-window -t all:0
    else
        tmux -q new \; linkw -t all
    fi
    exit
fi

# Create a new group for this session
#mkdir -pm 0700 /sys/fs/cgroup/cpu/user/$$
#echo $$ > /sys/fs/cgroup/cpu/user/$$/tasks

export PS1='\n\d \t\n\u@\h (\!)\n\w\$ '

# Completion
if [ -f /etc/bash_completion ]
then
	source /etc/bash_completion
    set completion-ignore-case on
fi

# Shell options
shopt -s cdspell
shopt -s dotglob
shopt -s cmdhist
shopt -s nocaseglob
shopt -s histappend
shopt -s checkwinsize
shopt -u force_fignore
shopt -s no_empty_cmd_completion

# History settings
export HISTFILESIZE=999999
export HISTSIZE=999999
export HISTCONTROL=erasedups,ignoreboth
export HISTTIMEFORMAT='%F %T '
export HISTIGNORE='&:exit'
export PROMPT_COMMAND='history -a; history -n'

# Directory traversing
#export CDPATH='.:~'
..() { if [ $1 -ge 0 2> /dev/null ]; then x=$1; else x=1; fi; for (( i = 0; i < $x; i++ )); do cd ..; done; }
mkcd() { mkdir -p "$*"; cd "$*"; }
alias p='pushd'
alias b='popd'
alias m='~/bin/dmntnir.sh'
r() {
    ~/bin/ranger/ranger.py --fail-if-run $@ &&
        tdir=$(grep "^'" ~/.config/ranger/bookmarks | cut -b3-) &&
            cd "$tdir"
}

# ls options
export LS_OPTIONS='-lh'
alias l='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -A'
alias ld='ls $LS_OPTIONS -A -d */'
alias lt='ls $LS_OPTIONS -tr'
alias lss='ls $LS_OPTIONS -Sr'

# grep options
export GREP_OPTIONS='-i'
alias pg='ps -A | grep'
alias lg='ll | grep'
alias fgg='find | grep'

# vim helpers
v() { if [ -z $1 ]; then vim -c "normal '0"; else vim -p *$1*; fi }
vg() { vim -p $(grep -l "$*" *); }
alias vs='vim -c "set spell | set buftype=nofile"'
alias les='/usr/share/vim/vimcurrent/macros/less.sh'

# Colors
#if [ $COLORTERM ]; then
if [ 1 ]; then
    eval "`dircolors`"
    export PS1='\n\e[31;40m\d \t\e[0m\n\e[32;40m\u@\h (\!)\e[0m\n\w\$ '
    export LS_OPTIONS="$LS_OPTIONS --color=auto"
    export GREP_OPTIONS="$GREP_OPTIONS --color=auto"
    export LESS_TERMCAP_us=$'\e[32m'
    export LESS_TERMCAP_ue=$'\e[0m'
    export LESS_TERMCAP_md=$'\e[1;31m'
    export LESS_TERMCAP_me=$'\e[0m'
fi

# Web shortcuts
alias webshare='python -c "import SimpleHTTPServer;SimpleHTTPServer.test()"'
alias wclip='curl -F "sprunge=<-" http://sprunge.us | xclip -f'
wclipfile() { curl -F "sprunge=@$1" http://sprunge.us | xclip -f; }
gc() {
    q=$(perl -MURI::Escape -e "print uri_escape(\"$*\");")
    a=$(curl -A 'mozilla/4.0' "http://www.google.com/search?q=$q" | grep 'class=r')
    echo; echo "$a" | perl -pe 's/.*class=r.*?<b>(.*?)<\/b>.*/\1/;' ;}
wg() { w3m -dump "http://google.com/search?q=$*" | les ;}
ww() { w3m -dump "http://en.wikipedia.org/w/index.php?title=Special:Search&search=$*&go=Go" | les ;}
wd() { w3m -dump "http://dictionary.reference.com/browse/$*" | les ;}

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

# Video handling
alias d0='DISPLAY=":0.0"'
alias d1='DISPLAY="localhost:10.0"'
alias mp='DISPLAY=":0.0" mplayer -fs -zoom'
alias mpl='DISPLAY=":0.0" mplayer -fs -zoom -lavdopts lowres=1:fast:skiploopfilter=all'
alias mpy='DISPLAY=":0.0" mplayer -fs -zoom -vf yadif'
alias webcam='mplayer tv:// -tv device=/dev/video0'
mplen() { gc `mplayer -vo dummy -ao dummy -identify "$1" 2>/dev/null | grep ID_LENGTH | cut -c 11-` seconds in minutes; }
flvit() { ffmpeg -loop_input -i $1 -i $2 -acodec copy -y -t `ffmpeg -i $2 |& grep 'Duration' | awk '{ print $2; }' | sed -e 's/,//g' | cut -b 2- ` $1.flv; }
mencode() { mencoder $* -aid 128 -info srcform='ripped by mencoder' -oac mp3lame -lameopts abr:br=128 -ovc xvid -xvidencopts pass=1:chroma_opt:vhq=4:bvhq=1:quant_type=mpeg -vf pp=de,crop=0:0:0:0, -ofps 30000/1001 -o '/dev/null' && mencoder $* -aid 128 -info srcform='ripped by mencoder' -oac mp3lame -lameopts abr:br=128 -ovc xvid -xvidencopts pass=2:bitrate=-700000 -ofps 30000/1001 -o output.avi; }

# Other aliases
alias d='trash'
alias dud='du --max-depth=1 -h | sort -h'
alias sc='screen -RAad'
alias startx='TMUX="" startx &'
alias tit='xsetroot -name'
alias canhaz='apt-get install $_'

# Autojump
source /etc/profile.d/autojump.bash

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
ls $LS_OPTIONS -tr --group-directories-first
