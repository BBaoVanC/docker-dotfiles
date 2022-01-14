FROM archlinux:base-devel
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
ENV DISABLE_SSH_AGENT=true
WORKDIR /home/user

COPY yay_install.sh /home/user
RUN ~/yay_install.sh

COPY repo_init.sh /home/user
COPY 0001-Remove-ssh-override-on-gitconfig.patch /home/user
RUN ~/repo_init.sh
RUN touch ~/.config/zsh/zshrc_nosync
# Run zshrc so it triggers zinit to clone all plugins
RUN zsh ~/.config/zsh/zshrc
# Running zshrc doesn't install gitstatusd for some reason
RUN ~/.cache/antibody/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-powerlevel10k/gitstatus/install
RUN nvim --headless +PlugInstall +qa

ENTRYPOINT /bin/zsh
