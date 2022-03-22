#!/bin/sh

cd
git init
git remote add origin https://github.com/BBaoVanC/dotfiles.git
git fetch
git checkout -f origin/master
git am < downloads/0001-Remove-ssh-override-on-gitconfig.patch
git submodule update --init .config/ranger/plugins/ranger_devicons
git -C .config/ranger/plugins/ranger_devicons checkout main
