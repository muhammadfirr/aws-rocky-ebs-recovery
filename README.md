# Rocky Linux EBS Recovery for Unbootable Instance

## Project Overview
This repository documents the process to recover a Rocky Linux 10 EBS root volume from an instance that became inaccessible via SSH after kernel updates.
The guide demonstrates skills in root volume inspection, UUID verification, GRUB configuration checks, network validation, and safe reattachment to a new instance.

---

## Environment

- **Cloud Provider:** AWS
- **Operating System:** Rocky Linux 10 (aarch64)
- **File System:** XFS
- **Networking:** ENI interface (ens5 / eth0 alias enp0s5)
- **Security:** SSH ports 22 & 2212, SELinux disabled

---

## Architecture
- Original instance: 10 GB root volume, kernel 6.12
- Recovery instance: Rocky Linux 10, attach old EBS as secondary volume (e.g., /dev/nvme1n1)
- Optional additional storage: snapshots, extra EBS volumes

---

## Recovery Steps
See `docs/recovery-guide.md` for a detailed step-by-step recovery workflow, including mounting old root, boot, EFI partitions, verifying UUIDs, GRUB and fstab checks, and network validation.

---

## Troubleshooting
- Instance not booting after kernel update
- Duplicate UUID conflicts between root volumes
- SSH inaccessible due to network misconfiguration or SELinux
- XFS filesystem inconsistencies

---

## Key Skills Demonstrated

- AWS EBS volume attachment & detachment
- XFS repair and UUID management (`xfs_repair`, `xfs_admin`)
- Root, boot, EFI mounting and bind-mounting for chroot
- GRUB configuration inspection
- Network interface validation for cloud-init
- Safe unmounting and reattachment to restore instance access

---

## Security Considerations

- Sensitive instance data is kept secure
- No real credentials or private keys included
- Only system configuration and metadata are documented
