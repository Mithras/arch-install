- Install (https://wiki.archlinux.org/title/Installation_guide)
  - [optional] ssh
    passwd
    ...
    ssh -o StrictHostKeychecking=no root@archiso
  - partition
    lsblk
    gdisk /dev/XXX
      n <default> <default> +1024M ef00
      n <default> <default> <default> <default>
      p
      w
  - format
    lsblk
    mkfs.fat -F32 /dev/XXX1
    mkfs.btrfs /dev/XXX2
  - subvolumes
    mount /dev/XXX2 /mnt
    cd /mnt
    btrfs subvolume create @
    btrfs subvolume create @home
    mkdir @/var
    btrfs subvolume create @/var/log
    btrfs subvolume create @/var/cache
    btrfs subvolume list .
    cd
    umount /mnt
  - mount
    lsblk --discard # non-zero DISC-GRAN and DISC-MAX indicate discard is supported
    mount -o defaults,noatime,space_cache=v2,discard=async,compress-force=zstd:1,subvol=@ /dev/XXX2 /mnt
    mount -m /dev/XXX1 /mnt/efi
    mount -m -o defaults,noatime,space_cache=v2,discard=async,compress-force=zstd:1,subvol=@home /dev/XXX2 /mnt/home
  - pacstrap
    pacstrap -K /mnt base git nano
  - fstab
    genfstab -U /mnt >> /mnt/etc/fstab
    nano /mnt/etc/fstab # remove "subvolid"
  - chroot
    arch-chroot /mnt
  - pacman.conf
    nano /etc/pacman.conf
      Color
      ParallelDownloads=5
      [multilib]
      Include=/etc/pacman.d/mirrorlist
    pacman -Sy
  - packages
    # cpu-intel
    pacman -S --needed intel-ucode

    # gpu-intel
    pacman -S --needed mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver
    
    # gpu-nvidia
    pacman -S --needed nvidia-dkms nvidia-settings nvidia-utils lib32-nvidia-utils egl-wayland nvtop

    # linux
    pacman -S --needed linux linux-headers linux-firmware dracut

    # audio
    pacman -S --needed pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack wireplumber

    # xorg/wayland
    pacman -S --needed xorg-server wayland xorg-xwayland

    # console
    pacman -S --needed sbctl reflector sudo btrfs-progs networkmanager networkmanager-openvpn bluez bluez-utils cifs-utils base-devel curl openssh rsync git docker docker-compose syncthing nano adobe-source-han-sans-jp-fonts flatpak fcitx5-im htop iwd timeshift

    # gui
    pacman -S --needed keepassxc qbittorrent mpv telegram-desktop strawberry steam ttf-liberation gamemode wine lib32-gnutls p7zip

    # kde
    pacman -S --needed plasma-meta kdegraphics-thumbnailers ffmpegthumbs
    # kde extra
    pacman -S --needed discover systemdgenie konsole dolphin ark plasma-systemmonitor spectacle gwenview ksystemlog yakuake sweeper kcalc filelight
    
    # gnome
    pacman -S --needed gnome-shell gdm xdg-desktop-portal xdg-desktop-portal-gnome gnome-backgrounds gnome-control-center tracker3-miners xdg-user-dirs-gtk gnome-shell-extension-appindicator gnome-tweaks
    # gnome extra
    baobab eog file-roller gnome-calculator gnome-clocks gnome-console gnome-logs gnome-system-monitor nautilus gvfs-mtp webp-pixbuf-loader
  - Time Zone
    ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
    hwclock --systohc
  - Localization
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
    locale-gen
  - Network
    export HOST='...'
    echo "$HOST" > /etc/hostname
    echo '127.0.0.1 locahost' >> /etc/hosts
    echo '::1 locahost' >> /etc/hosts
    echo "127.0.1.1 $HOST" >> /etc/hosts
    echo '[device]' > /etc/NetworkManager/conf.d/wifi_backend.conf
    echo 'wifi.backend=iwd' >> /etc/NetworkManager/conf.d/wifi_backend.conf
  - Boot Loader
    bootctl install
  - User
    export USER='...'
    useradd -m -G wheel $USER
    #btrfs subvolume create /home/$USER/.cache
  - Sudo
    echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel
  - Journal
    echo 'SystemMaxUse=256M' >> /etc/systemd/journald.conf
  - Fcitx #todo only 1 is needed?
    echo 'GTK_IM_MODULE=fcitx' >> /etc/environment
    echo 'QT_IM_MODULE=fcitx' >> /etc/environment
    echo 'XMODIFIERS=@im=fcitx' >> /etc/environment
  - secure boot
    sbctl create-keys
    sbctl status
    sbctl enroll-keys -m
    sbctl sign -s /efi/EFI/systemd/systemd-bootx64.efi
    sbctl sign -s /efi/EFI/BOOT/BOOTX64.EFI
  - Dracut #todo use git repo?
    export UUID=$(blkid -o value -s UUID /dev/XXX2)
    pushd ./dracut
    mkdir -p /etc/pacman.d/hooks
    cp dracut.sh /usr/local/bin/dracut.sh
    cp dracut.conf /usr/local/bin/dracut.conf
    cp dracut.hook /etc/pacman.d/hooks/dracut.hook
    sed -i -E "s/UUID=[^ ]+/UUID=$UUID/g" /usr/local/bin/dracut.conf
    nano /usr/local/bin/dracut.conf
    nano /usr/local/bin/dracut.sh
    /usr/local/bin/dracut.sh
    popd
  - passwords
    passwd root
    passwd $USER
  - reboot
    Ctrl+D
    reboot
- Post install
  - Systemd
    sudo systemctl enable --now NetworkManager
    sudo systemctl enable --now systemd-timesyncd
    sudo systemctl enable --now bluetooth
    sudo systemctl enable --now docker
    sudo systemctl enable --now sshd
    sudo systemctl enable --now cronie
    sudo systemctl enable fstrim.timer
    sudo systemctl enable reflector.timer
    sudo systemctl enable btrfs-scrub@-.timer
    systemctl --user enable --now syncthing
  - sysctl overrides
    echo 'vm.max_map_count=1048576' | sudo tee -a /etc/sysctl.d/90-override.conf
  - paru
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
  - KDE
    echo '[Wallet]' > ~/.config/kwalletrc
    echo 'Enabled=false' >> ~/.config/kwalletrc
    sudo systemctl enable --now sddm
  - Gnome
    sudo systemctl enable --now gdm
  - SSH Agent
    mkdir -p ~/.config/systemd/user
    cat <<EOF > ~/.config/systemd/user/ssh-agent.service
    [Unit]
    Description=SSH key agent

    [Service]
    Type=simple
    Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
    ExecStart=/usr/bin/ssh-agent -D -a \$SSH_AUTH_SOCK

    [Install]
    WantedBy=default.target
    EOF

    mkdir -p ~/.config/environment.d
    echo 'SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"' > ~/.config/environment.d/ssh_auth_socket.conf

    export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
    systemctl --user enable --now ssh-agent
  - Apps    
    - Syncthing
    - Keepass
    - fcitx
  - aur
    paru -S paru-bin
    paru -S brave-bin
    paru -S visual-studio-code-bin
  - flatpak
    flatpak install flathub com.github.tchx84.Flatseal
    flatpak install net.davidotek.pupgui2
    flatpak install com.skype.Client
    flatpak install flathub us.zoom.Zoom
  - autostart
    - arch-install/scripts/load-nvidia-settings.sh
    - arch-install/scripts/ssh-add.sh
    - telegram -startintray -- %u
