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
  - install.sh
    git clone https://github.com/Mithras/arch-install.git
    cd ./arch-install

    nano ./install.sh # review/update

    ./install.sh
  - secure boot
    sbctl status
    sbctl enroll-keys -m
  - password
    passwd
    passwd XXX
  - reboot
    Ctrl+D
    umount -R /mnt
    reboot
- Post install
  - post-install.sh
    git clone https://github.com/Mithras/arch-install.git
    cd ./arch-install/post-install
    
    code ./post-install.sh # review/update
    ./post-install.sh

    ./ssh-agent.sh
    
    code ./snapper.sh # review/update
    ./snapper.sh

    # syncthing
    # keepass
    # fcitx
  - aur
    paru -S paru-bin
    paru -S brave-bin
    paru -S sddm-git
    paru -S visual-studio-code-bin
  - flatpak
    flatpak install flathub com.github.tchx84.Flatseal
    flatpak install net.davidotek.pupgui2
    flatpak install com.skype.Client
    flatpak install flathub us.zoom.Zoom
  - autostart
    # ~/Documents/src/arch-install/autostart/load-nvidia-settings.sh
    # ~/Documents/src/arch-install/autostart/ssh-add.sh
    # telegram -startintray -- %u
    # easyeffects --gapplication-service
