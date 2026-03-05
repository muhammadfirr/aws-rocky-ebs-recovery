#!/bin/bash

# Rocky Linux EBS Recovery UUID Check Script
# This script verifies filesystem UUIDs and compares them with fstab

echo "Checking block devices and filesystems"

lsblk -f

echo "Checking root UUID"

sudo blkid /dev/nvme1n1p3

echo "Checking boot UUID"

sudo blkid /dev/nvme1n1p2

echo "Checking EFI UUID"

sudo blkid /dev/nvme1n1p1

echo "Checking fstab configuration"

sudo cat /mnt/oldroot/etc/fstab

echo "Checking GRUB root configuration"

sudo cat /mnt/oldroot/boot/grub2/grub.cfg | grep root=

echo "UUID verification completed"
