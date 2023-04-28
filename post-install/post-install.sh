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

# sysctl overrides
echo 'vm.max_map_count=1048576' | sudo tee -a /etc/sysctl.d/90-override.conf

# paru
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# KDE
echo '[Wallet]' > $HOME/.config/kwalletrc
echo 'Enabled=false' >> $HOME/.config/kwalletrc
sudo systemctl enable --now sddm

# Gnome
#systemctl enable gdm
