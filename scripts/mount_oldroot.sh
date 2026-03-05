#!/bin/bash

# Rocky Linux EBS Recovery Mount Script
# This script mounts the old root filesystem and required system directories
# for recovery or inspection.

set -e

echo "Creating mount directory..."

sudo mkdir -p /mnt/oldroot

echo "Mounting root partition..."
sudo mount /dev/nvme1n1p3 /mnt/oldroot

echo "Mounting boot partition..."
sudo mount /dev/nvme1n1p2 /mnt/oldroot/boot

echo "Mounting EFI partition..."
sudo mount /dev/nvme1n1p1 /mnt/oldroot/boot/efi

echo "Binding system directories..."

sudo mount --bind /dev /mnt/oldroot/dev
sudo mount --bind /proc /mnt/oldroot/proc
sudo mount --bind /sys /mnt/oldroot/sys
sudo mount --bind /run /mnt/oldroot/run

echo "--------------------------------------"
echo "Old system mounted successfully"
