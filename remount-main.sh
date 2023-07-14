#!/usr/bin/env bash
set -e

sudo umount /mnt/main
sudo mount -t cifs -o username=mithras,uid=$USER,gid=$USER //synology/Main /mnt/main
