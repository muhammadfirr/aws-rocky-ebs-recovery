# AWS Rocky Linux 10 EBS Recovery

## Overview

This guide describes the full recovery procedure for a Rocky Linux 10 EC2 instance that became unreachable via SSH after kernel updates.
The goal is to attach the old root EBS to a new instance, verify filesystem integrity, and ensure the system is bootable.

## 1. Detach the Old EBS
- Stop the affected EC2 instance (recommended) or ensure the root EBS volume is offline.
- Detach the root volume from the instance via AWS Management Console or CLI:
```bash
aws ec2 detach-volume --volume-id vol-xxxxxxxx
```
- Note the volume ID and size (e.g., 20 GB).

## 2. Attach to a Recovery Instance
- Launch a new Rocky Linux 10 instance (matching architecture).
- Attach the old EBS as a secondary device, e.g., /dev/nvme1n1:
```bash
aws ec2 attach-volume --volume-id vol-xxxxxxxx --instance-id i-xxxxxxxx --device /dev/nvme1n1
```
- Verify attachment:
```bash
lsblk
```
- Expected output:
```bash
nvme0n1   10G  (new root)
nvme1n1   20G  (old root attached)
```

## 3. Mount Old Root and Partitions
- Create mount points and mount the old filesystem:
```bash
sudo mkdir -p /mnt/oldroot
sudo mount /dev/nvme1n1p3 /mnt/oldroot         # old root
sudo mount /dev/nvme1n1p2 /mnt/oldroot/boot    # boot partition
sudo mount /dev/nvme1n1p1 /mnt/oldroot/boot/efi # EFI partition
```
- Bind system directories to chroot:
```bash
sudo mount --bind /dev /mnt/oldroot/dev
sudo mount --bind /proc /mnt/oldroot/proc
sudo mount --bind /sys /mnt/oldroot/sys
sudo mount --bind /run /mnt/oldroot/run
```

## 4. Verify Root Filesystem
- Check UUID of old root:
```bash
sudo blkid /dev/nvme1n1p3
```
- If UUID duplicates a live root, generate a new UUID:
```bash
sudo xfs_admin -U generate /dev/nvme1n1p3
```
- Update /mnt/oldroot/etc/fstab with the new UUID for root:
```bash
UUID=<new-uuid> / xfs defaults 0 1
UUID=<boot-uuid> /boot xfs defaults 0 0
UUID=<efi-uuid> /boot/efi vfat defaults,umask=0077,shortname=winnt 0 0
```
- Note: Boot and EFI UUIDs can remain the same if partitions are unchanged.

## 5. Verify GRUB Configuration
- Check the kernel and root UUID:
```bash
cat /mnt/oldroot/boot/grub2/grub.cfg | grep -E 'linux|initrd|root='
```
- Ensure the root=UUID= points to the new UUID of the old root.
- GRUB installation is optional if using UEFI; ensure grub.cfg exists.

## 6. Verify Network Configuration
- Check ENI interface exists (ens5 / eth0 alias enp0s5).
- Verify cloud-init configuration:
```bash
sudo cat /mnt/oldroot/etc/NetworkManager/system-connections/cloud-init-ens5.nmconnection
```
- Ensure mac-address and method=auto are configured; no sensitive data exposed.

## 7. Optional: Chroot & Final Checks
```bash
sudo chroot /mnt/oldroot
sestatus      # SELinux status
grubby --default-kernel   # Verify default kernel
exit
```
- Kernel modules present
- SELinux disabled or permissive
- Network interface configured
- Root UUID consistent with fstab

## 8. Unmount Old Root & Cleanup
```bash
sudo umount /mnt/oldroot/run
sudo umount /mnt/oldroot/sys
sudo umount /mnt/oldroot/proc
sudo umount /mnt/oldroot/dev
sudo umount /mnt/oldroot/boot/efi
sudo umount /mnt/oldroot/boot
sudo umount /mnt/oldroot
```

## 9. Reattach Old Root to Original Instance
- Detach from recovery instance.
- Attach back to original instance as /dev/nvme0n1 (or original device).
- Start the instance.
