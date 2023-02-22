#!/usr/bin/env bash
set -e

UUID='2b93b382-67ee-4fd2-9da9-fee023e432e6'
HOST='mithras-pc'
USER='mithras'

# Packages (common cpu-intel gpu-nvidia gpu-intel kde gnome)
pushd ./packages
pacman -S --needed $(<common) $(<cpu-intel) $(<gpu-nvidia) $(<kde)
popd

# Time Zone
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc

# Localization
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen

# Network
echo "$HOST" > /etc/hostname
echo '127.0.0.1 locahost' >> /etc/hosts
echo '::1 locahost' >> /etc/hosts
echo "127.0.1.1 $HOST" >> /etc/hosts
echo '[device]' > /etc/NetworkManager/conf.d/wifi_backend.conf
echo 'wifi.backend=iwd' >> /etc/NetworkManager/conf.d/wifi_backend.conf

# Boot Loader
sbctl create-keys
bootctl install
sbctl sign -s /efi/EFI/systemd/systemd-bootx64.efi
sbctl sign -s /efi/EFI/BOOT/BOOTX64.EFI

# Dracut
pushd ./dracut
sed -i -E "s/UUID=[^ ]+/UUID=$UUID/g" dracut.conf
mkdir -p /etc/pacman.d/hooks
cp dracut.sh /usr/local/bin/dracut.sh
cp dracut.conf /usr/local/bin/dracut.conf
cp dracut.hook /etc/pacman.d/hooks/dracut.hook
/usr/local/bin/dracut.sh
popd

# User
useradd -m -G wheel $USER
btrfs subvolume create /home/$USER/.cache

# Sudo
echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel

# Journal
echo 'SystemMaxUse=256M' >> /etc/systemd/journald.conf

# Fcitx
echo 'GTK_IM_MODULE=fcitx' >> /etc/environment
echo 'QT_IM_MODULE=fcitx' >> /etc/environment
echo 'XMODIFIERS=@im=fcitx' >> /etc/environment
