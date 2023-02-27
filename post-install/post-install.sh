#!/usr/bin/env bash
set -e

# Systemd
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now systemd-timesyncd
sudo systemctl enable --now bluetooth
sudo systemctl enable --now docker
sudo systemctl enable --now sshd
sudo systemctl enable fstrim.timer
sudo systemctl enable reflector.timer
sudo systemctl enable btrfs-scrub@-.timer
systemctl --user enable --now syncthing

# Yay
git clone https://aur.archlinux.org/yay.git $HOME
cd yay
makepkg -si

# KDE
echo '[Wallet]' > $HOME/.config/kwalletrc
echo 'Enabled=false' >> $HOME/.config/kwalletrc
sudo systemctl enable --now sddm

# Gnome
#systemctl enable gdm
