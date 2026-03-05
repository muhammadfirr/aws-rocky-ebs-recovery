#!/bin/bash

# Rocky Linux EBS Recovery Unmount Script
# Safely unmounts all mounted recovery directories

set -e

echo "Unmounting bind mounts..."

sudo umount /mnt/oldroot/run || true
sudo umount /mnt/oldroot/sys || true
sudo umount /mnt/oldroot/proc || true
sudo umount /mnt/oldroot/dev || true

echo "Unmounting boot partitions..."

sudo umount /mnt/oldroot/boot/efi || true
sudo umount /mnt/oldroot/boot || true

echo "Unmounting root partition..."

sudo umount /mnt/oldroot || true

echo "--------------------------------------"
echo "All mounts removed successfully"
