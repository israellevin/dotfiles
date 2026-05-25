#!/bin/bash
# shellcheck disable=SC1090

if [ "$EUID" = 0 ]; then
    cat > ./etc/apt/apt.conf <<EOF
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF
    DEBIAN_FRONTEND=noninteractive apt -y install \
        keyd kmod irqbalance numad \
        linux-perf pciutils psmisc strace sudo usbutils \
        bash-completion bc bsdextrautils git jq less locales man moreutils pv ripgrep socat vim zoxide \
        chafa console-setup git-delta tmux \
        cpio gpg openssl unrar unzip zstd \
        ca-certificates dhcpcd5 iproute2 netbase \
        aria2 curl iputils-ping iwd openssh-server rfkill rsync sshfs w3m wget
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

if ! type uv >/dev/null 2>&1; then
    uv_version="$(curl -fsSL https://astral.sh/uv/install.sh | grep APP_VERSION= | cut -d'"' -f2)"
    uv_base_url=https://releases.astral.sh/github/uv/releases/download
    curl -fsSL "$uv_base_url/$uv_version/uv-x86_64-unknown-linux-gnu.tar.gz" | \
        tar xz --strip-components=1 -C ~/bin
    export PATH="$PATH:$HOME/bin"
fi

if ! [ -e ~/bin/python ]; then
    uv venv ~/bin/python
    . ~/bin/python/bin/activate
    uv pip install basedpyright llm pygments python-lsp-server ruff-lsp
fi

if ! [ -e ~/bin/node ]; then
    export N_PREFIX=~/bin/node
    curl -fsSL https://raw.githubusercontent.com/mklement0/n-install/stable/bin/n-install | \
        bash -s -- -y
    export PATH="$PATH:$N_PREFIX/bin"
fi

if ! [ -e ~/bin/node/node_modules ]; then
    npm --prefix ~/bin/node install \
        bash-language-server \
        npm@latest \
        webtorrent-cli
fi

if ! [ -e ~/bin/cargo ]; then
    export CARGO_HOME=~/bin/cargo
    curl -fsSL https://sh.rustup.rs | \
        sh -s -- -y --default-toolchain stable --profile minimal --no-modify-path
fi

wget https://github.com/sxyazi/yazi/releases/download/nightly/yazi-x86_64-unknown-linux-gnu.zip
unzip yazi-x86_64-unknown-linux-gnu.zip
mv yazi-x86_64-unknown-linux-gnu/ya* ~/bin/.
rm yazi-x86_64-unknown-linux-gnu.zip

git clone https://github.com/laktak/extrakto
mv extrakto ~/bin/.

git clone https://github.com/brendangregg/FlameGraph
( cd FlameGraph && rm -rf .git demos docs test example-* )
mv FlameGraph ~/bin/flamegraph

mkdir -p ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/0xProto.zip
unzip -ud ~/.local/share/fonts 0xProto.zip
rm 0xProto.zip

LC_ALL=en_US.UTF-8 vim +:qa
[ "$1" = --non-interactive ] || . ~/.bashrc
