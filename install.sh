#!/bin/sh

if [ "$EUID" = 0 ]; then
    cat > ./etc/apt/apt.conf <<EOF
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF
    DEBIAN_FRONTEND=noninteractive apt -y install \
        bash bash-completion chafa console-setup git git-delta locales mc tmux vim \
        cpio gzip tar unrar unzip zstd \
        bc bsdextrautils bsdutils mawk moreutils pciutils psmisc pv sed ripgrep usbutils \
        ca-certificates dhcpcd5 iproute2 netbase \
        aria2 curl iputils-ping openssh-server w3m wget \
        firmware-iwlwifi iw wpasupplicant \
        docker.io docker-cli nodejs npm python3-pip python3-venv
    echo en_US.UTF-8 UTF-8 > /etc/locale.gen
    locale-gen
fi

cd "$(dirname "$(realpath "$0")")" || exit 1
if ! git remote show -n origin 2>/dev/null | grep -q '^ *Fetch URL:.*israellevin/dotfiles\(.git\)*$'; then
    git clone https://israellevin@github.com/israellevin/dotfiles
    cd dotfiles
fi

git clone https://github.com/clvv/fasd
mv fasd/fasd ./bin/.
rm -rf fasd

wget git.io/trans
chmod +x ./trans
mv ./trans ./bin/.

find . -maxdepth 1 -type f -name '.*' -exec cp -at ~ {} +
cp -a ./bin ./.config ~/.

python3 -m venv ~/bin/python
. ~/bin/python/bin/activate
pip install --upgrade pip setuptools
pip install pygments python-lsp-server shell-gpt

npm --prefix ~/bin install npm@latest typescript-language-server webtorrent-cli
rm ~/bin/package.json ~/bin/package-lock.json

git clone https://github.com/Jelmerro/Vieb ~/src/vieb
npm --prefix ~/src/vieb install

LC_ALL=en_US.UTF-8 vim +:qa
[ "$1" = --non-interactive ] || . ~/.bashrc

exit
