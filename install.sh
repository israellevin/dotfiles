#!/bin/bash

if [ "$1" = --apt-install ]; then
    shift
    apt-get --no-install-recommends --no-install-suggests install \
        bash-completion bc bsdextrautils curl git locales mc moreutils psmisc tmux unzip vim tmux vim wget
    echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
    locale-gen
fi

pushd "$(dirname "$(realpath "$0")")" || exit 1


git remote show -n origin 2>/dev/null | grep -q '^ *Fetch URL:.*israellevin/dotfiles\(.git\)*$' ||
    git clone https://israellevin@github.com/israellevin/dotfiles && cd dotfiles

git clone https://github.com/clvv/fasd
mv fasd/fasd ./bin/.
rm -rf fasd

wget git.io/trans
chmod +x ./trans
mv ./trans ./bin/.

cp --preserve=all ./.* ~/.
cp -a ./bin ./.config ~/.

LC_ALL=en_US.UTF-8 vim +:qa
[ -t 0 ] && . ~/.bashrc

exit
