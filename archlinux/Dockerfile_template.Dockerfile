FROM archlinux:IMAGE_TAG
LABEL MAINTAINER="bbaovanc@bbaovanc.com"

RUN pacman -Syu --noconfirm
RUN pacman -S --needed --noconfirm sudo curl git gcc make zsh neovim python python-pip python-setuptools python-neovim yarn fzf ranger highlight mediainfo

RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN useradd -mG wheel user
RUN chsh -s /bin/zsh user


USER user
SHELL ["/bin/zsh", "-c"]
ENV USER=user
ENV TERM=xterm-256color
ENV DISABLE_SSH_AGENT=true
WORKDIR /home/user

COPY repo_init.sh /home/user
RUN ~/repo_init.sh
RUN touch ~/.config/zsh/zshrc_nosync
# Run zshrc so it triggers zinit to clone all plugins
RUN zsh ~/.zshrc
# Running zshrc doesn't install gitstatusd for some reason
RUN ~/.zinit/plugins/romkatv---powerlevel10k/gitstatus/install
RUN nvim --headless +PlugInstall +qa

ENTRYPOINT /bin/zsh