#!/bin/bash

umount /mnt/main
mount -t cifs -o username=mithras,uid=mithras,gid=mithras //synology/Main /mnt/main
