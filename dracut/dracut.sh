#!/usr/bin/env bash
set -e

kernels=('/usr/lib/modules/*/pkgbase')

for kernel in ${kernels[@]}; do
  if [[ "$kernel" == '/usr/lib/modules/'+([^/])'/pkgbase' ]]; then
    pkgbase=`cat $kernel`
    kver="${kernel#'/usr/lib/modules/'}"
    kver="${kver%'/pkgbase'}"

    dracut -c /usr/local/bin/dracut.conf --force --kver "$kver" --hostonly "/efi/EFI/Linux/archlinux-$pkgbase.efi"
    dracut -c /usr/local/bin/dracut.conf --force --kver "$kver" --no-hostonly "/efi/EFI/Linux/archlinux-$pkgbase-fallback.efi"
    sbctl sign -s "/efi/EFI/Linux/archlinux-$pkgbase.efi"
    sbctl sign -s "/efi/EFI/Linux/archlinux-$pkgbase-fallback.efi"
    rsync -a --delete /efi/ /.efibackup
  fi
done
