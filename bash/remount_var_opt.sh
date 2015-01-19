#!/bin/bash

. /etc/profile

/sbin/mkfs.ext3 /dev/sdb1
mount /dev/sdb1 /mnt/
rsync -avH /var/opt/ /mnt/
umount /mnt
cp /etc/fstab /etc/bak_fstab
echo "/dev/sdb1               /var/opt                    ext3    defaults        1 2" >> /etc/fstab
mv /var/opt /var/opt.old
mkdir /var/opt
mount -a
restorecon -R -v /var/opt
df -h
