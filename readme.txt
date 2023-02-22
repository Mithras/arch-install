- Install (https://wiki.archlinux.org/title/Installation_guide)
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
    mkdir @home/mithras
    btrfs subvolume create @home/mithras/.cache
    btrfs subvolume list .
    cd
    umount /mnt
  - mount
    lsblk --discard # non-zero DISC-GRAN and DISC-MAX mean discard is supported
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
  - arch-install
    mkdir -p /home/mithras/Documents/src
    cd /home/mithras/Documents/src
    git clone https://github.com/Mithras/arch-install.git
    cd ./arch-install

    nano ./packages/common # review/update
    nano ./install.sh # review/update

    ./install.sh
  - secure boot
    sbctl status
    sbctl enroll-keys -m
    /usr/local/bin/dracut.sh
  - password
    passwd
    passwd mithras
  - reboot
    Ctrl+D
    umount -R /mnt
    reboot
- Post install
  - arch-install
    cd ~/Documents/src/arch-install/post-install
    nano ./post-install.sh # review/update

    ./post-install.sh
    #./yay.sh
    #./flatpak.sh
  - snapper (https://wiki.archlinux.org/title/snapper)
    # TODO: script
    cd ~/Documents/src/arch-install/snapper
    
    snapper -c @ create-config /
    snapper -c @home create-config /home
    snapper list-configs
    
    cp @ /etc/snapper/configs/@
    cp @home /etc/snapper/configs/@home

    mount /dev/nvme0n1p2 /mnt
    cd /mnt
    btrfs subvolume list .
    btrfs subvolume delete @/.snapshots
    btrfs subvolume delete @home/.snapshots
    btrfs subvolume create @snapshots
    btrfs subvolume create @snapshots/@
    btrfs subvolume create @snapshots/@home
    btrfs subvolume list .
    cd
    umount /mnt

    mkdir /.snapshots /home/.snapshots
    code /etc/fstab
      UUID=XXX /.snapshots btrfs rw,noatime,compress-force=zstd:1,ssd,discard=async,space_cache=v2,subvol=@snapshots/@ 0 0
      UUID=XXX /home/.snapshots btrfs rw,noatime,compress-force=zstd:1,ssd,discard=async,space_cache=v2,subvol=@snapshots/@home 0 0
    mount -a
    lsblk

    systemctl enable --now snapper-timeline.timer
    systemctl enable --now snapper-cleanup.timer

    # Snapshots on boot
    # code /usr/lib/systemd/system/snapper-boot.service
    #   ConditionPathExists=/etc/snapper/configs/@
    #   ConditionPathExists=/etc/snapper/configs/@home
    #   ExecStart=/usr/bin/snapper -c @ create -c number -d boot
    #   ExecStart=/usr/bin/snapper -c @home create -c number -d boot
    # systemctl enable snapper-boot.timer
  - wol (https://wiki.archlinux.org/title/Wake-on-LAN)
    nmcli c modify "XXX" 802-3-ethernet.wake-on-lan magic
    # nmcli c show "XXX" | grep 802-3-ethernet.wake-on-lan
    
    # pacman -S ngrep
    # ngrep '\xff{6}(.{6})\1{15}' -x port 9
  - autostart
    # ~/Documents/src/arch-install/autostart/load-nvidia-settings.sh
    # ~/Documents/src/arch-install/autostart/ssh-add.sh
    # telegram with "-startintray"
  - config
    - openssh (https://wiki.archlinux.org/title/OpenSSH)
      # https://infosec.mozilla.org/guidelines/openssh.html
      code /etc/ssh/sshd_config
        AuthenticationMethods publickey
        PermitRootLogin No
      code ~/.ssh/authorized_keys # add .pub
    - chrome
      code ~/.config/chrome-flags.conf
        --force-dark-mode
        --enable-features=WebUIDarkMode
        --ignore-gpu-blocklist
        --enable-gpu-rasterization
        --enable-zero-copy
    - mangohud (https://wiki.archlinux.org/title/MangoHud)
      mkdir ~/.config/MangoHud
      cp /usr/share/doc/mangohud/MangoHud.conf.example ~/.config/MangoHud/MangoHud.conf
      code ~/.config/MangoHud/MangoHud.conf
        fps_limit=117
        gpu_stats
        gpu_temp
        gpu_core_clock
        cpu_stats
        cpu_temp
        cpu_mhz
        fps
        frametime
        frame_timing
        font_scale=1.5
        table_columns=4
      # mangohud %command% # some OpenGL games might also need --dlsym
    - gamemode (https://github.com/FeralInteractive/gamemode)
      curl -o ~/.config/gamemode.ini https://raw.githubusercontent.com/FeralInteractive/gamemode/master/example/gamemode.ini
      code ~/.config/gamemode.ini
        start=qdbus org.kde.KWin /Compositor org.kde.kwin.Compositing.suspend
        end=qdbus org.kde.KWin /Compositor org.kde.kwin.Compositing.resume
      # mangohud gamemoderun %command%
    - mpv (https://wiki.archlinux.org/title/Mpv)
      cp -r /usr/share/doc/mpv/ ~/.config/
      code ~/.config/mpv/mpv.conf
        profile=gpu-hq
        scale=ewa_lanczossharp
        cscale=ewa_lanczossharp
        interpolation
        tscale=oversample
  - gamepad
    bluetoothctl
      power on
      scan on
      pair XXX
      scan off
      trust XXX
      connect XXX
  - smb
    code /root/.smbcredentials
      username=XXX
      password=XXX
    chmod 600 /root/.smbcredentials
    code /etc/fstab
      //synology/Main /mnt/main cifs noauto,x-systemd.automount,_netdev,credentials=/root/.smbcredentials 0 0
  - extra
    - zram (https://wiki.archlinux.org/title/Zram)
      echo 0 > /sys/module/zswap/parameters/enabled
      pacman -S zram-generator
      code /etc/systemd/zram-generator.conf
        [zram0]
        zram-size=min(ram / 4, 8192)
        compression-algorithm=zstd
      systemctl enable --now systemd-zram-setup@zram0
      echo 'vm.swappiness=200' > /etc/sysctl.d/99-swappiness.conf
      # sysctl vm.swappiness
    - winetricks
      pacman -S winetricks
    - obs
      pacman -S obs-studio v4l2loopback-dkms linux-headers
    - kde
      pacman -S kdenlive krdc kleopatra kompare kgpg kamera
    - gnome
      pacman -S gnome-disk-utility gnome-font-viewer gnome-remote-desktop gvfs-smb dconf-editor ghex gnome-connections sysprof
      yay -S gnome-shell-extension-pop-shell-bin
    - virt-manager (https://wiki.archlinux.org/title/Virt-Manager)
      pacman -S virt-manager qemu-desktop
      code /etc/libvirt/libvirtd.conf
        unix_sock_group='libvirt'
        unix_sock_rw_perms='0770'
      systemctl enable --now libvirtd.service
      usermod -a -G libvirt $USER
      code /etc/libvirt/qemu.conf
        user="mithras"
        group="mithras"
      # https://www.microsoft.com/en-us/software-download/windows10
      # https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
      # https://github.com/Fmstrat/winapps/blob/main/docs/KVM.md#create-your-virtual-machine
    - ventoy (https://wiki.archlinux.org/title/Ventoy)
      yay -S ventoy-bin
      /opt/ventoy/Ventoy2Disk.sh
      # or
      /opt/ventoy/VentoyGUI.x86_64
    - alvr
      yay -S sidequest-bin
      pacman -S rustup 
      rustup default stable
      rustup update
      yay -S alvr
      # or
      yay -S alvr-git
