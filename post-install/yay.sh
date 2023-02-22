#!/usr/bin/env bash
set -e

cd ~/Documents/src
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

#yay -S $(<../packages/aur)
