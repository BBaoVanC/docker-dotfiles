#!/bin/sh

mkdir ~/downloads/
cd ~/downloads/
git clone https://aur.archlinux.org/yay.git
cd yay/
makepkg -sic --noconfirm
