#!/usr/bin/env bash
set -eu

: "$UUID"

sudo snapper -c @ create-config /
sudo snapper -c @home create-config /home
sudo btrfs subvolume delete /.snapshots
sudo btrfs subvolume delete /home/.snapshots
# snapper list-configs

pushd ../snapper
sudo cp @ /etc/snapper/configs/@
sudo cp @home /etc/snapper/configs/@home
popd

sudo mount UUID=$UUID /mnt
pushd /mnt
sudo btrfs subvolume create @snapshots
sudo btrfs subvolume create @snapshots/@
sudo btrfs subvolume create @snapshots/@home
popd
sudo umount /mnt
# sudo btrfs subvolume list .

sudo mkdir /.snapshots /home/.snapshots

cat << EOF | sudo tee -a /etc/fstab

UUID=$UUID /.snapshots btrfs rw,noatime,compress-force=zstd:1,ssd,discard=async,space_cache=v2,subvol=/@snapshots/@ 0 0
UUID=$UUID /home/.snapshots btrfs rw,noatime,compress-force=zstd:1,ssd,discard=async,space_cache=v2,subvol=/@snapshots/@home 0 0
EOF
sudo mount -a
# lsblk

sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer

# Snapshots on boot
# code /usr/lib/systemd/system/snapper-boot.service
#   ConditionPathExists=/etc/snapper/configs/@
#   ConditionPathExists=/etc/snapper/configs/@home
#   ExecStart=/usr/bin/snapper -c @ create -c number -d boot
#   ExecStart=/usr/bin/snapper -c @home create -c number -d boot
# systemctl enable snapper-boot.timer
