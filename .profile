git clone https://israellevin@github.com/israellevin/dotfiles && \
git clone https://github.com/clvv/fasd && \
wget git.io/trans && \
cp -r dotfiles/bin dotfiles/.* . && \
rm -r .git && \
mv fasd/fasd bin/. &&\
rm -r fasd &&\
mv trans bin/. &&\
echo '[ "$BASH" ] && . ~/.bashrc' > .profile
