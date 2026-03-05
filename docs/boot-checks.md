# Rocky Linux 10 Boot Validation Checks

## Overview
This document provides verification steps to ensure that a recovered Rocky Linux 10 EBS volume can boot correctly when attached back to an EC2 instance. These checks confirm that the root filesystem, GRUB configuration, kernel, network, and SSH settings are correct.
This guide assumes the recovered volume is mounted at:

/mnt/oldroot

---

## 1. Verify Root Filesystem UUID
- Ensure the root partition UUID matches the configuration inside `/etc/fstab`.
- Check the actual filesystem UUID
```bash
sudo blkid /dev/nvme1n1p3
```
Expected output example:
```
/dev/nvme1n1p3: LABEL="rocky" UUID="76cxxxxx4-xx1a-xxx9-axxc-4xxxxxxxxxa" TYPE="xfs"
```
- Now verify `/etc/fstab` inside the recovered root:
```bash
sudo cat /mnt/oldroot/etc/fstab
```
Example:
```
UUID=76cxxxxx4-xx1a-xxx9-axxc-4xxxxxxxxxa / xfs defaults 0 1
UUID=xxxxxx9-caff-4ff8-xxx7-8xxxx7xxxxb /boot xfs defaults 0 0
UUID=xxx2-x7xD /boot/efi vfat defaults,umask=0xx7,shortname=winnt 0 0
The UUID for `/` must match the root filesystem UUID.
```

## 2. Verify GRUB Configuration
- Check that GRUB references the correct root UUID.
```bash
sudo cat /mnt/oldroot/boot/grub2/grub.cfg | grep -E 'linux|initrd|root='
```
Example expected output:
```
set kernelopts="root=UUID=76cxxxxx4-xx1a-xxx9-axxc-4xxxxxxxxxa ro console=ttyS0,115200n8"
```
Confirm that:
- The root UUID matches the actual filesystem UUID
- Kernel boot parameters exist
- GRUB configuration is readable

## 3. Verify Installed Kernels
- Check that kernel images exist inside `/boot`.
```bash
ls /mnt/oldroot/boot/vmlinuz-*
```
Example output:
```
/mnt/oldroot/boot/vmlinuz-6.12.0-124.29.1.el10_1.aarch64
/mnt/oldroot/boot/vmlinuz-6.12.0-124.31.1.el10_1.aarch64
/mnt/oldroot/boot/vmlinuz-6.12.0-124.35.1.el10_1.aarch64
```
- Also verify initramfs files:
```bash
ls /mnt/oldroot/boot/initramfs*
```
- These files are required for successful boot.

# 4. Verify Boot and EFI Partitions
- Check that `/boot` and `/boot/efi` partitions are mounted correctly.
```bash
lsblk -f
```
Expected example:
```
nvme1n1p1 vfat  EFI
nvme1n1p2 xfs   BOOT
nvme1n1p3 xfs   rocky
```
- Mount them if necessary:

```bash
sudo mount /dev/nvme1n1p2 /mnt/oldroot/boot
sudo mount /dev/nvme1n1p1 /mnt/oldroot/boot/efi
```

## 5. Verify Network Configuration
- Check the NetworkManager configuration created by cloud-init.
```bash
sudo cat /mnt/oldroot/etc/NetworkManager/system-connections/cloud-init-ens5.nmconnection
```
Example configuration:
```
[connection]
id=cloud-init ens5
type=ethernet

[ipv4]
method=auto
may-fail=false
```

Important checks:
- Interface name should be **ens5**
- IPv4 method should be **auto**
- Configuration should exist

AWS Nitro instances commonly use:
- ens5
- eth0 (alias)
- enp0s5

These are automatically detected during boot.

## 6. Verify SSH Configuration
- Ensure SSH daemon is configured correctly.
- Check SSH configuration file:
```bash
sudo cat /mnt/oldroot/etc/ssh/sshd_config
```
Important settings:
```
Port 22
```
or
```
Port 22
Port 2212
```
- Multiple ports are allowed.

## 7. Verify SELinux Status
- Check whether SELinux is enabled or disabled.
```bash
sudo chroot /mnt/oldroot
sestatus
```
Example output:
```
SELinux status: disabled
```
- If SELinux is disabled, it will not block SSH access.

## 8. Verify Network Interface Detection
Check which interfaces exist on the recovery instance.
```bash
ip link show
```
Example output:
```
ens5: <BROADCAST,MULTICAST,UP,LOWER_UP>
```
- This confirms the expected AWS network interface.

## 9. Optional Boot Simulation Check
- Enter the recovered system environment using chroot.
Mount system directories:
```bash
sudo mount --bind /dev /mnt/oldroot/dev
sudo mount --bind /proc /mnt/oldroot/proc
sudo mount --bind /sys /mnt/oldroot/sys
sudo mount --bind /run /mnt/oldroot/run
```
- Enter chroot:
```bash
sudo chroot /mnt/oldroot
```
- Inside chroot you can test:
```
grubby --default-kernel
cat /etc/fstab
```
- Exit chroot when finished:
```
exit
```

## 10. Final Validation Checklist
- Before attaching the recovered EBS back to an instance, confirm the following:
- Root filesystem UUID matches `/etc/fstab`
- GRUB configuration references correct UUID
- Kernel and initramfs files exist in `/boot`
- Boot and EFI partitions mount successfully
- Network configuration exists (cloud-init)
- SSH daemon configuration is valid
- SELinux will not block SSH
- No filesystem corruption detected

---

## Result
If all checks pass, the EBS volume should boot successfully when attached as the root volume of an EC2 instance.
