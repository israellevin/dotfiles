# shellcheck disable=SC1090  # Do not follow sources.
# shellcheck disable=SC2015  # Allow non-if-else trinary form.
# Don't do shit if not connected to a terminal.
[ -t 0 ] || return

# Only launch graphical environment if attached to tty1.
[ "$(tty)" = /dev/tty1 ] && [ -z "$TMUX" ] && exec ~/bin/niri.sh

# Multiplex.
if type tmux >/dev/null 2>&1 && [ ! "$TMUX" ]; then
    unattached_sessions=("$(tmux list-sessions 2>/dev/null | grep -v '(attached)')")
    if [ ${#unattached_sessions[0]} -eq 0 ]; then
        tmux -TRGB new-session
    else
        tmp_session=tmp$(tr -dc '0-9' < /dev/urandom | head -c4)
        tmux new-session -ds "$tmp_session" \
            "tmux choose-tree -s 'switch-client -t %%; kill-session -t $tmp_session'; exec bash"
        tmux -TRBG attach-session -t "$tmp_session"
    fi
    [ -e ~/dontquit ] || exit 0
fi

# Steal all tmux windows into current session.
muxjoin() {
    for win in $(tmux list-windows -aF "#{session_name}:#{window_index}"); do
        [ "$win" = "$(tmux display-message -p '#{session_name}:#{window_index}')" ] && continue
        tmux move-window -ds "$win"
    done
}

# Truisms.
user_path="$HOME/bin"
user_path="$user_path:$HOME/bin/python/bin"
user_path="$user_path:$HOME/bin/cargo/bin"
user_path="$user_path:$HOME/bin/node/bin"
user_path="$user_path:$HOME/bin/node/node_modules/.bin"
export PATH="$user_path:$PATH:/sbin"
export LANG=en_US.UTF-8
export EDITOR=vim
export BROWSER=brows
export PATH LANG EDITOR BROWSER

# Shell options.
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

# History.
HISTFILE=~/.bash_history_safe
HISTFILESIZE=
HISTSIZE=
HISTCONTROL=ignoreboth
HISTTIMEFORMAT='%F %T '
HISTIGNORE='&:exit'
PROMPT_COMMAND='history -a; history -n'

# Enable bash Completions.
. /etc/bash_completion
complete -C '/home/i/bin/aws_completer' aws

# Generic completion copier.
declare -A COMPLETE_AS=()
_complete_as() {
    local as=${COMPLETE_AS[${COMP_WORDS[0]}]-}
    local IFS=$' \t\n'
    local -a replacement original_words=("${COMP_WORDS[@]}")
    read -ra replacement <<< "$as"
    local joined=${replacement[*]}
    local original=${original_words[0]}
    local COMP_LINE=$joined${COMP_LINE#"$original"}
    local COMP_POINT=$((COMP_POINT + ${#joined} - ${#original}))
    local COMP_CWORD=$((COMP_CWORD + ${#replacement[@]} - 1))
    local -a COMP_WORDS=("${replacement[@]}" "${original_words[@]:1}")
    local dispatch=_comp_command_offset
    declare -F "$dispatch" >/dev/null 2>&1 || dispatch=__command_offset
    "$dispatch" 0
}
copy_completion() {
    COMPLETE_AS["$1"]="${*:2}"
    complete -F _complete_as "$1"
}
alias_with_completion() {
    local command
    printf -v command '%q ' "${@:2}"
    # shellcheck disable=SC2139  # Expand on definition
    alias "$1=$command"
    copy_completion "$@"
}
# General functions.
dud() { du -hxd1 "${1:-.}" | sort -h; }
exp() { curl -Gs "https://www.mankier.com/api/explain/?cols=$(tput cols)" --data-urlencode "q=$*"; }
from_json() { node -pe "JSON.parse(require('fs').readFileSync(0, 'utf-8'))$1"; }
genpas() { shuf -zern"${1:-8}" ':' ';' '<' '=' '>' '?' '@' '[' ']' '^' '_' '`' '{' '|' '}' '~' {0..9} {A..Z} {a..z} {a..z} {a..z}; echo; }
log() { "$@" 2>&1 | tee log.txt; }
long() { "$@"; notify-send -- "$1 is done"; }
noslp() { systemd-inhibit --what=handle-lid-switch:sleep:shutdown --why='manual inhibition' sleep infinity; }
pg() { g "$@" <<<"$(ps -eF --forest | sort)"; }
slp() { echo mem > /sys/power/state; }
sume() { [ "$EUID" -ne 0 ] && sudo -E su -p; }
til() { sleep $(( $(date -d "$*" +%s) - $(date +%s) )); }
timediff() {
    diff="$(date -d @$(( $(date -d "$3 $4" +%s) - $(date -d "$1 $2" +%s) )) -u +%Y-%j-%T)"
    orig_ifs=$IFS
    IFS=-
    while read -r y d t; do
        echo $((y - 1970)) $((d - 1)) "$t"
    done <<< "$diff"
    IFS=$orig_ifs
}
venv() {
    local venv_dir="${1:-./venv}"
    if ! . ./"$venv_dir"/bin/activate 2>/dev/null; then
        uv venv "$venv_dir"
        . ./"$venv_dir"/bin/activate
    fi
    alias pip='uv pip'
    if [ -f requirements.txt ]; then
        missing_packages="$(comm -23 <(sort requirements.txt) <(uv pip freeze | grep -v '0.0.0' | sort))"
        if [ "$missing_packages" ]; then
            read -rn1 -p "$missing_packages - install (y/N)? "
            echo
            [[ $REPLY =~ ^[Yy]$ ]] && uv pip install -r requirements.txt
        fi
    fi
    if [ -f pyproject.toml ]; then
        read -rn1 -p "found pyproject.toml - install (y/N)? "
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && uv pip install --upgrade -e .
    fi
}
w() {
    fzf --query="^$*" < /usr/share/dict/words
}
_w() {
    mapfile -t COMPREPLY < <(g -h "^${COMP_WORDS[COMP_CWORD]}" /usr/share/dict/words)
}
complete -F _w w
webshare() {
    local command=(python3 -m http.server)
    [ "$1" ] && command+=(-d "$1")
    "${command[@]}" &
    sleep 0.1
    w3m -dump http://localhost:8000 | head
    wait
}

# Filesystem traversal.
alias b='popd'
..() {
    local target="${1:-1}"
    if [ "$target" -eq "$target" ] 2>/dev/null; then
        for(( i = 0; i < target; i++ )); do c .. || return 1; done;
        return 0
    else
        target="${PWD%%"$target"*}$target*"
        pushd "$target" && return 0
    fi
    return 1
}
_..() {
    compopt -o filenames
    IFS=/ read -ra parts <<< "$PWD"
    unset 'parts[-1]'
    mapfile -t COMPREPLY < <(printf '%s\n' "${parts[@]}" | g "${COMP_WORDS[COMP_CWORD]}")
}
complete -F _.. ..
c() {
    local target="${1:-$HOME}"
    [ "$(pwd)" == "$(readlink -f "$target")" ] && return 0
    pushd "$target" || return 1
}
copy_completion c cd
mkcd() { mkdir -p "$*"; c "$*" || return 1; }
xs() {
    [ -d "$*" ] 2>/dev/null && pushd "$*" && return
    dirs=()
    while read -r dir ;do
        dirs+=("$dir")
    done < <(find . -type d -iname "*${*%% }*" 2>/dev/null)
    case ${#dirs[@]} in
        0)
            return 1
            ;;
        1)
            pushd "${dirs[@]}" || return 1
            ;;
        *)
            select dir in "${dirs[@]}" ; do
                pushd "$dir" || return 1
                break
            done
            ;;
    esac
}
y() {
    local tmp
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -rd '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && pushd -- "$cwd" || return 1
    rm -f -- "$tmp"
}

# Completion.
. /etc/bash_completion

# ls.
LS_OPTIONS=(-lh --color=auto --quoting-style=shell)
alias_with_completion l ls "${LS_OPTIONS[@]}"
alias_with_completion ll l -A
alias_with_completion lt l -tr
alias_with_completion llt lt -A
alias_with_completion lld ll -d -- */
alias_with_completion lls ll -Sr

# grep.
type rg >/dev/null 2>&1 && alias g='rg --smart-case' || alias g='grep --color=auto -i'
lg() { ll "${2:-.}" | g "$1"; }
fgg() { find "${2:-.}" | g "$1"; }

# vim.
# shellcheck disable=SC2086  # We want word splitting here.
vv() { [ -z "$1" ] && vim -c "normal '0" || vim -p -- ./*$**; } # Open last file or all filenames matching argument.
# shellcheck disable=SC2046  # We want word splitting here.
vg() { vim -p $(g -lF -- "$*"); } # Open all files containing argument.
vd() {
    local lines
    mapfile -t lines < <(diff -rq "$1" "$2")
    for line in "${lines[@]}"; do
        echo "$line"
        if [[ $line =~ ^Only\ in\ (.*):\ (.*)$ ]]; then
            local directory_containing_file="${BASH_REMATCH[1]}"
            local missing_file="${BASH_REMATCH[2]}"
            local directory_missing_file
            [ "$directory_containing_file" = "$2" ] && \
                directory_missing_file="$1" || \
                directory_missing_file="$2"
            read -rn1 -p "Copy missing file (y/N)? "
            [[ $REPLY =~ ^[Yy]$ ]] && \
                cp -a "$directory_containing_file/$missing_file" "$directory_missing_file/"
        elif [[ $line =~ ^Files\ (.*)\ and\ (.*)\ differ$ ]]; then
            local file1="${BASH_REMATCH[1]}"
            local file2="${BASH_REMATCH[2]}"
            read -rn1 -p "Open in vimdiff (y/N)? "
            [[ $REPLY =~ ^[Yy]$ ]] && \
                vimdiff "$file1" "$file2"
        else
            echo "Unknown diff output: $line"
            return 1
        fi
    done
}

# git.
gitformat="%s %C(dim)%C(cyan)%ah %C(green)%al %C(magenta)%h%C(auto)%d"
alias_with_completion gl git log --graph --abbrev-commit --pretty=format:"$gitformat"
alias_with_completion glg gl --all
alias_with_completion gll glg --exclude=refs/remotes/** --all --decorate-refs=refs/heads/
alias_with_completion gs git status
gmb() { git merge-base "$(git branch --show-current)" "${1:-master}"; }
gcur() { git branch --show-current; }
gremtrack() { git rev-parse --abbrev-ref --symbolic-full-name '@{u}'; }
gresetlocal() { git reset --hard "$(gcur)"; }
gresetremote() { git reset --hard "$(gremtrack)"; }

# fzf.
export FZF_DEFAULT_OPTS='--exact --no-sort --bind=ctrl-u:page-up,ctrl-d:page-down,alt-o:print-query,ctrl-o:replace-query'
export FZF_CTRL_T_OPTS='--preview=~/.fzf/bin/fzf-preview.sh\ {}'
export FZF_TMUX=1
[ -f ~/.fzf.bash ] && . ~/.fzf.bash

# zoxide.
eval "$(zoxide init bash --cmd j)"

# LLM.
rewrite_command() {
    [ "$READLINE_LINE" ] || return 0
    READLINE_LINE="$(~/bin/sanj 'do' - "$READLINE_LINE")"
    READLINE_POINT=${#READLINE_LINE}
}
bind -x '"\C-g": rewrite_command'

# Media.
cap() { slurp | grim -g - "${1:-tmp}.png"; }
feh() { foot sh -c "chafa --duration inf '$*'" 2>/dev/null; }
vol() {
    local sink=@DEFAULT_AUDIO_SINK@;
    if [ "$1" ]; then
        wpctl set-mute $sink 0
        wpctl set-volume $sink "$1"
    else
        wpctl set-mute $sink toggle
    fi
    wpctl get-volume $sink
}
blu() {
    local bluetooth_id
    bluetooth_id=$(rfkill list | grep -Po '^\d(?=: hci\d: Bluetooth)')
    rfkill unblock "$bluetooth_id"
    bluetoothctl power on
    bluetoothctl
    bluetoothctl power off
    rfkill block "$bluetooth_id"
}
tit() { echo "sub-add '$1'" | socat - /tmp/mpv.sock; }

# Some escape sequences for colors.
# Note the surrounding $'\001' and $'\002'  which tell readline the escape.
# sequence has zero length.  Bash documentation recommends using escaped square.
# brackets, but these fail on command substitution.
rgb_escape_code() { printf "\001\033[38;2;%d;%d;%dm\002" "$1" "$2" "$3"; }
tput_escape_code() { printf "\001%s\002" "$(tput "$1")"; }
RED="$(rgb_escape_code 178 148 187)"
GREEN="$(rgb_escape_code 71 180 19)"
YELLOW="$(rgb_escape_code 255 175 0)"
BLUE="$(rgb_escape_code 39 59 150)"
MAGENTA="$(rgb_escape_code 204 102 153)"
CYAN="$(rgb_escape_code 102 204 204)"
REVERSE="$(tput_escape_code rev)"
RESET="$(tput_escape_code sgr0)"

# Easy view.
type dircolors >/dev/null 2>&1 && eval "$(dircolors)"
type lesspipe >/dev/null 2>&1 && eval "$(lesspipe)"
export LESS=' -MRSXF '
export LESS_TERMCAP_us=$GREEN
export LESS_TERMCAP_ue=$RESET
export LESS_TERMCAP_md=$RED
export LESS_TERMCAP_me=$RESET
export MANPAGER='vim +MANPAGER --not-a-term -c "nmap <buffer><nowait> q :q<CR>" -'
alias pyg='pygmentize -gf terminal256 -O style=monokai'
pygl() { pyg "$@" | less; }

# Prompt.
gitstat() {
    local orig_retcode=$?
    local stats
    mapfile -t stats < <(git status --porcelain=v2 --branch --show-stash 2>/dev/null)
    [ "${stats[0]}" ] || return $orig_retcode
    local line branch aheadbehind ahead behind stash dirty conflict untracked
    for line in "${stats[@]}"; do
        case "$line" in
            "# branch.head "*)
                branch=${line#*head }
                if [ "$branch" = "(detached)" ]; then
                    branch=$(git rev-parse --short HEAD 2>/dev/null)
                    local git_dir
                    git_dir=$(git rev-parse --git-dir 2>/dev/null)
                    if [ -d "$git_dir/rebase-merge" ] || [ -d "$git_dir/rebase-apply" ]; then
                        branch="rebase on $branch"
                    elif [ -f "$git_dir/BISECT_LOG" ]; then
                        branch="bisect on $branch"
                    fi
                fi
                ;;
            "# branch.ab "*)
                # shellcheck disable=SC2086  # We want word splitting here.
                mapfile -d' ' -ts2 aheadbehind <<<$line
                ahead=${aheadbehind[0]%+0}
                behind=${aheadbehind[1]%$'\n'}
                behind=${behind%-0}
                ;;
            "# stash "*) stash="[${line#'# stash '}]";;
            "1 "*|"2 "*) ((dirty++));;
            "u "*) ((conflict++));;
            "? "*) ((untracked++));;
        esac
    done
    echo -n "($MAGENTA$stash$YELLOW$branch$GREEN$behind$ahead"
    [ "$dirty" ] && echo -n " $MAGENTA$dirty"
    [ "$conflict" ] && echo -n " ${RED}$conflict"
    [ "$untracked" ] && echo -n " ${BLUE}$untracked"
    echo -n "$RESET)"
    return $orig_retcode
}
hasjobs() {
    local orig_retcode=$?
    local pids
    local num_pids
    mapfile -t pids < <(jobs -p)
    num_pids=${#pids[@]}
    [ "$num_pids" -gt 0 ] && echo "$num_pids"
    return $orig_retcode
}
retcode() {
    local orig_retcode=$?
    [ 0 != "$orig_retcode" ] && echo $orig_retcode
    return $orig_retcode
}
hostorchrootname() {
    local orig_retcode=$?
    ischroot && cat /etc/hostname || hostname
    return $orig_retcode
}

if [ "$PROMPT_MODE" = single-line ]; then
    PS1="$MAGENTA$REVERSE\$(retcode)$RESET$RED\u@\$(hostorchrootname):$RESET"
    PS1+="$GREEN\W$RESET\$(gitstat)$CYAN$REVERSE\$(hasjobs)$RESET\$ "
else
    PS0="$BLUE/ \D{%d-%b-%y %H:%M:%S} \\$RESET\n"
    PS1="$BLUE\\\\ \D{%d-%b-%y %H:%M:%S} /$RESET\n"
    PS1+="$RED\u@\$(hostorchrootname)(\!):$RESET$GREEN\w$RESET\$(gitstat)\n"
    PS1+="$MAGENTA$REVERSE\$(retcode)$RESET$CYAN$REVERSE\$(hasjobs)$RESET\$ "
fi

lt
