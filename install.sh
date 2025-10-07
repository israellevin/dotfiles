#!/bin/bash
# shellcheck disable=SC1090

if [ "$EUID" = 0 ]; then
    cat > ./etc/apt/apt.conf <<EOF
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF
    DEBIAN_FRONTEND=noninteractive apt -y install \
        bc bsdextrautils bsdutils jq linux-perf mawk moreutils pciutils psmisc pv sed ripgrep usbutils \
        bash-completion chafa console-setup git git-delta less locales man mc tmux vim \
        cpio gzip tar unrar unzip zstd \
        ca-certificates dhcpcd5 iproute2 netbase \
        aria2 curl iputils-ping iwd openssh-server rfkill rsync sshfs w3m wget \
        debootstrap make python3-pip python3-venv shellcheck \
        cliphist fonts-noto fonts-noto-color-emoji grim slurp wl-clipboard wlsunset wlrctl wmenu
    echo en_US.UTF-8 UTF-8 > /etc/locale.gen
    locale-gen
fi

cd "$(dirname "$(realpath "$0")")" || exit 1
if ! git remote show -n origin 2>/dev/null | grep -q '^ *Fetch URL:.*israellevin/dotfiles\(.git\)*$'; then
    git clone https://israellevin@github.com/israellevin/dotfiles
    cd dotfiles || exit 1
fi

find . -maxdepth 1 -type f -name '.*' -exec cp -at ~ {} +
cp -a ./bin ./.config ~/.

if ! [ -e ~/bin/python ]; then
    python3 -m venv ~/bin/python
    . ~/bin/python/bin/activate
    pip install --upgrade pip setuptools
    pip install llm pygments python-lsp-server python-lsp-ruff shell-gpt uv
fi

if ! [ -e ~/bin/node ]; then
    export N_PREFIX=~/bin/node
    curl https://raw.githubusercontent.com/mklement0/n-install/stable/bin/n-install | bash -s -- -y
    export PATH="$PATH:$N_PREFIX/bin"
fi

if ! [ -e ~/bin/node/node_modules ]; then
    npm --prefix ~/bin/node install \
        bash-language-server \
        npm@latest \
        https://github.com/Jelmerro/Vieb \
        webtorrent-cli \
        typescript-language-server
fi

# Fix Vieb app's index.js to work with our directory structure.
sed --in-place -e 's|"\.\./node_modules/|"../../../node_modules/|' ~/bin/node/node_modules/vieb/app/index.js

if ! [ -e ~/bin/cargo ]; then
    export CARGO_HOME=~/bin/cargo
    curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable --profile minimal --no-modify-path
fi

git clone https://github.com/clvv/fasd
mv fasd/fasd ~/bin/.
rm -rf fasd

git clone https://github.com/laktak/extrakto
mv extrakto ~/bin/.

git clone https://github.com/brendangregg/FlameGraph
( cd FlameGraph && rm -rf .git demos docs test example-* )
mv FlameGraph ~/bin/flamegraph

curl -sL https://archlinux.org/packages/extra/x86_64/wiremix/download/ | \
    tar x --zstd --strip-components=2 usr/bin/wiremix
mv ./wiremix ~/bin/.

wget git.io/trans
chmod +x ./trans
mv ./trans ~/bin/.

mkdir -p ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/0xProto.zip
unzip -ud ~/.local/share/fonts 0xProto.zip
rm 0xProto.zip

LC_ALL=en_US.UTF-8 vim +:qa
[ "$1" = --non-interactive ] || . ~/.bashrc
