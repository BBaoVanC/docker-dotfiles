#!/bin/sh

cd
git init
git remote add origin https://github.com/BBaoVanC/dotfiles.git
git fetch
git checkout -f origin/master
