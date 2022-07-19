# Create the base image
FROM archlinux:base-devel-20220717.0.68836 AS base
RUN sed -i 's/^#Color$/Color/' /etc/pacman.conf
RUN echo "keyserver keyserver.ubuntu.com" >> /etc/pacman.d/gnupg/gpg.conf
RUN pacman -Syu --noconfirm
RUN sudo pacman -D --asexplicit curl file gcc make
RUN sudo pacman -S --noconfirm sudo zsh git

# Can't run makepkg as root either so might as well set up user
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN useradd -mG wheel user
RUN chsh -s /bin/zsh user

USER user
SHELL ["/bin/zsh", "-c"]
ENV USER=user
ENV TERM=xterm-256color
WORKDIR /home/user


# Create base image for building AUR packages
FROM base AS aur-builder
RUN sudo pacman -S --noconfirm go


# Build yay (AUR helper)
FROM aur-builder AS yay-builder
RUN git clone https://aur.archlinux.org/yay.git /tmp/yay/
RUN (cd /tmp/yay/ && makepkg --noconfirm)


# Build lf (terminal file browser)
FROM aur-builder AS lf-builder
RUN git clone https://aur.archlinux.org/lf.git /tmp/lf/
RUN (cd /tmp/lf/ && makepkg --noconfirm)


# ==================================================================== #


# The final image
FROM base AS docker-dotfiles
LABEL MAINTAINER="bbaovanc@bbaovanc.com"


# Install built AUR packages
COPY --from=yay-builder /tmp/yay/*.pkg.tar.zst /tmp
RUN sudo pacman -U --noconfirm /tmp/yay*.pkg.tar.zst
RUN rm /tmp/yay*.pkg.tar.zst

COPY --from=lf-builder /tmp/lf/*.pkg.tar.zst /tmp
RUN sudo pacman -U --noconfirm /tmp/lf*.pkg.tar.zst
RUN rm /tmp/lf*.pkg.tar.zst

# Set up repo
ARG DOTFILES_COMMIT=7c95d30200df9c82c0525d9af0178279ea4e18de
RUN git init
RUN git remote add origin https://github.com/BBaoVanC/dotfiles.git
RUN git fetch
RUN git checkout ${DOTFILES_COMMIT}

# Apply patches for docker-dotfiles
COPY --chown=user:user patches/ /tmp/patches/
RUN git am --no-gpg-sign /tmp/patches/*
RUN rm -rf /tmp/patches/

# Clone submodules
RUN git submodule update --init --recursive

# Run zshrc so it triggers antibody to clone all plugins
RUN zsh ~/.config/zsh/zshrc
# Running zshrc doesn't install gitstatusd for some reason
RUN ~/.cache/antibody/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-powerlevel10k/gitstatus/install

RUN sudo pacman -S --noconfirm neovim npm yarn
RUN nvim --headless +PlugInstall +qa
RUN npm -C ~/.config/coc/extensions/ install


# Utility packages
RUN sudo pacman -S --needed --noconfirm \
        tree fd fzf ranger \
        man-db man-pages texinfo \
        dnsutils mediainfo ncdu \
        python python-pip python-setuptools python-virtualenv python-neovim python-pillow


# Cleanup
RUN sudo rm /var/cache/pacman/pkg/*


ENTRYPOINT /bin/zsh
