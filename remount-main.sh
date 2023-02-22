#!/usr/bin/env bash
set -e

umount /mnt/main
mount -t cifs -o username=mithras,uid=$USER,gid=$(id -gn) //synology/Main /mnt/main
