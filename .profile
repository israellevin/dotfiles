apt-get --no-install-recommends install \
bash-completion bc bsdmainutils file git ntpdate vim tmux \
cgroup-bin gawk locales imagemagick libfribidi-bin mc moreutils poppler-utils psmisc wamerican-insane \
aria2 ca-certificates curl dhcpcd5 iproute2 openssh-server sshfs w3m wget \
wireless-tools wpasupplicant \
acpi pm-utils sensord \
alsa-base alsa-utils apvlv mpv \
x11-xserver-utils xautomation xdotool xinit xserver-xorg xserver-xorg-input-kbd xserver-xorg-video-vesa \
clipit feh redshift rxvt-unicode-256color unclutter vim-gtk \
conkeror conkeror-spawn-process-helper xul-ext-firebug \
flashplugin-nonfree

echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen

git clone https://israellevin@github.com/israellevin/dotfiles
cp -r dotfiles/bin .
cp dotfiles/.* .

git clone https://github.com/clvv/fasd
mv fasd/fasd bin/.
rm -r fasd

wget git.io/trans
mv trans bin/.

echo '[ "$BASH" ] && . ~/.bashrc' > .profile

LC_ALL=en_US.UTF-8 vi +:qa
. .bashrc
