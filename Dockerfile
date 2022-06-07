FROM archlinux:base-devel-20220522.0.57327
LABEL MAINTAINER="bbaovanc@bbaovanc.com"

RUN echo "keyserver keyserver.ubuntu.com" >> /etc/pacman.d/gnupg/gpg.conf

RUN pacman -Syu --noconfirm
RUN pacman -S --needed --noconfirm sudo curl git gcc make zsh neovim python python-pip python-setuptools python-neovim yarn fzf ranger highlight mediainfo man-db man-pages texinfo imagemagick python-pillow dnsutils

RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN useradd -mG wheel user
RUN chsh -s /bin/zsh user


USER user
SHELL ["/bin/zsh", "-c"]
ENV USER=user
ENV TERM=xterm-256color
WORKDIR /home/user

COPY yay_install.sh /home/user
RUN ~/yay_install.sh

# Set up repo
COPY repo_init.sh /home/user
COPY dotfiles-commit.txt /home/user
RUN ~/repo_init.sh

# Apply patches for docker-dotfiles
COPY patches/ /home/user/downloads/patches/
RUN git am --no-gpg-sign downloads/patches/*

RUN touch ~/.config/zsh/zshrc_nosync
# Run zshrc so it triggers antibody to clone all plugins
RUN zsh ~/.config/zsh/zshrc
# Running zshrc doesn't install gitstatusd for some reason
RUN ~/.cache/antibody/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-powerlevel10k/gitstatus/install
RUN nvim --headless +PlugInstall +qa
RUN sudo pacman -S --noconfirm npm
RUN npm -C ~/.config/coc/extensions/ install

ENTRYPOINT /bin/zsh
