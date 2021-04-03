FROM debian:IMAGE_TAG
LABEL MAINTAINER="bbaovanc@bbaovanc.com"

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y apt-utils
RUN apt-get install -y curl git zsh neovim python3 python3-pip python3-setuptools python3-neovim nodejs yarn fzf ranger

RUN useradd -mG sudo user
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
