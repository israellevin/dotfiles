if [ ! $UID = 0 ]; then
    sudo -E $0
    exit 0
fi

apt-get --no-install-recommends install bash-completion git locales tmux vim
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen

cd

[ -d dotfiles ] || git clone https://israellevin@github.com/israellevin/dotfiles
cp dotfiles/.* .
cp -r dotfiles/bin .
cp -r dotfiles/.config .

git clone https://github.com/clvv/fasd
mv fasd/fasd bin/.
rm -r fasd

wget git.io/trans
mv trans bin/.

LC_ALL=en_US.UTF-8 vim +:qa

. .bashrc
