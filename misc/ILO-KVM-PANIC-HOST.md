# README

A baremetal server is inaccessible! But we can log into the iLo and do things. How can we get the initramfs crash log?!

Well hopefully the iLO KVM supports virtual media mounts. And I have a initramfs crash shell.

1. `dd if=/dev/zero of=foo.img bs=1M count=25`
2. `mkfs ext4 -F foo.img`
3. Virtual Drives -> Image File Removable Media -> `foo.img`
4. `mount /dev/sdX /mnt`
5. `cp /run/initramfs/rdsosreport.txt /mnt`
6. `umount /mnt`
7. Virtual Drives -> Image File Removable Media
8. Mount on host and enjoy the file... Good luck!

## Alt:

1. `truncate -s 1G foo.img`
2. `mkfs.ext4 foo.img`
3. `mount -oloop foo.img /mnt`
4. (opt) `resize2fs -M foo.img`
5. (opt) `truncate -s ??? foo.img`
