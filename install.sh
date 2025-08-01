#!/bin/bash

cd "$(dirname "$(realpath "$0")")" || exit 1
if ! git remote show -n origin 2>/dev/null | grep -q '^ *Fetch URL:.*israellevin/dotfiles\(.git\)*$'; then
    git clone https://israellevin@github.com/israellevin/dotfiles
    cd dotfiles
fi

if [ "$EUID" = 0 ]; then
    cat > ./etc/apt/apt.conf <<EOF
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF
    DEBIAN_FRONTEND=noninteractive apt -y install \
        bash-completion chafa console-setup git git-delta less locales man mc tmux vim \
        cpio gzip tar unrar unzip zstd \
        bc bsdextrautils bsdutils mawk moreutils pciutils psmisc pv sed ripgrep usbutils \
        ca-certificates dhcpcd5 iproute2 netbase \
        aria2 curl iputils-ping openssh-server sshfs w3m wget
    echo en_US.UTF-8 UTF-8 > /etc/locale.gen
    locale-gen
fi

mkdir -p ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/0xProto.zip
unzip -ud ~/.local/share/fonts 0xProto.zip
rm 0xProto.zip

git clone https://github.com/clvv/fasd
mv fasd/fasd ./bin/.
rm -rf fasd

wget git.io/trans
chmod +x ./trans
mv ./trans ./bin/.

python3 -m venv ~/bin/python
. ~/bin/python/bin/activate
pip install --upgrade pip setuptools
pip install pygments python-lsp-server shell-gpt

export CARGO_HOME=~/bin/cargo
[ -d ~/bin/cargo ] || \
    curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable --profile minimal --no-modify-path
export PATH="$CARGO_HOME:$PATH"

[ -d ~/bin/n ] || \
    curl https://raw.githubusercontent.com/mklement0/n-install/stable/bin/n-install | N_PREFIX=~/bin/n bash -s -- -y
export PATH="$HOME/bin/n/bin:$PATH"

npm --prefix ~/bin install \
    npm@latest \
    https://github.com/Jelmerro/Vieb \
    webtorrent-cli \
    typescript-language-server
rm ~/bin/package.json ~/bin/package-lock.json

find . -maxdepth 1 -type f -name '.*' -exec cp -at ~ {} +
cp -a ./bin ./.config ~/.

LC_ALL=en_US.UTF-8 vim +:qa
[ "$1" = --non-interactive ] || . ~/.bashrc

exit
