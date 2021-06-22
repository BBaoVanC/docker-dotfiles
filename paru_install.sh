#!/bin/sh

mkdir ~/downloads/
cd ~/downloads/
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin/
makepkg -sic --noconfirm
