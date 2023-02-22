#!/usr/bin/env bash
set -e

# Systemd
systemctl enable --now NetworkManager
systemctl enable --now systemd-timesyncd
systemctl enable --now bluetooth
systemctl enable --now docker
systemctl enable --now syncthing@$USER
systemctl enable --now sshd
systemctl enable fstrim.timer
systemctl enable reflector.timer
systemctl enable btrfs-scrub@-.timer

# KDE
echo '[Wallet]' > ~/.config/kwalletrc
echo 'Enabled=false' >> ~/.config/kwalletrc
systemctl enable --now sddm

# Gnome
#systemctl enable gdm
