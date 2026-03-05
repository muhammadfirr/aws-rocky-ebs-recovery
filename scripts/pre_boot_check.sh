#!/bin/bash

# Rocky Linux EBS Recovery - Pre Boot Validation Script
# This script performs multiple checks before reattaching the recovered EBS
# to ensure the system can boot correctly.

echo "Rocky Linux Recovery - Pre Boot Validation"

echo ""
echo "1. Checking mounted filesystems"
lsblk

echo ""
echo "2. Checking filesystem UUIDs"
sudo blkid

echo ""
echo "3. Verifying /etc/fstab configuration"
sudo cat /mnt/oldroot/etc/fstab

echo ""
echo "4. Checking GRUB root configuration"
sudo cat /mnt/oldroot/boot/grub2/grub.cfg | grep root=

echo ""
echo "5. Checking installed kernels"
ls /mnt/oldroot/boot/vmlinuz-*

echo ""
echo "6. Checking initramfs images"
ls /mnt/oldroot/boot/initramfs-*

echo ""
echo "7. Checking SSH configuration"
sudo cat /mnt/oldroot/etc/ssh/sshd_config | grep Port

echo ""
echo "8. Checking network configuration"
sudo ls /mnt/oldroot/etc/NetworkManager/system-connections/

echo ""
echo "9. Checking SELinux status"
sudo chroot /mnt/oldroot sestatus 2>/dev/null || echo "SELinux not available"

echo ""
echo "10. Checking default kernel"
sudo chroot /mnt/oldroot grubby --default-kernel 2>/dev/null || echo "Cannot check kernel"

echo ""
echo "Pre-boot validation completed"
echo "If all configurations look correct,"
echo "the EBS volume should be safe to boot."
