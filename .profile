apt-get --no-install-recommends install \
    cgroup-bin flashplugin-nonfree gawk locales ntpdate wamerican-insane

echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen

git clone https://github.com/clvv/fasd
mv fasd/fasd bin/.
rm -r fasd

wget git.io/trans
mv trans bin/.

echo '[ "$BASH" ] && . ~/.bashrc' > .profile

LC_ALL=en_US.UTF-8 vi +:qa
. .bashrc
