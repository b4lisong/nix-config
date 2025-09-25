# NAS Configuration

This document describes the NAS server configuration and setup procedures.

## System Overview

### Hardware Configuration
- **Platform**: HP MicroServer Gen8 (legacy BIOS, AHCI mode)
- **Boot Storage**: Internal SD card (HP iLO) for GRUB bootloader
- **System Storage**: 500GB SSD in ODD port with ZFS root pool (`rpool`)
- **Data Storage**: 4x4TB drives in RAIDZ10 configuration (`storage` pool)
- **Memory**: 16GB RAM with ZFS ARC limited to 4GB
- **Architecture**: x86_64 with Intel KVM support

### ZFS Pools
- **rpool**: System pool on SSD with datasets for `/`, `/nix`, `/var`, `/home`, `/incus`
- **storage**: Data pool with datasets for `/mnt/app_config`, `/mnt/media`, `/mnt/backup`

## HP MicroServer Gen8 Specific Configuration

### Boot Architecture Overview
The HP MicroServer Gen8 has a known limitation where the ODD (Optical Disk Drive) port cannot boot directly in AHCI mode. This configuration uses a workaround:

1. **Internal SD Card**: Contains GRUB bootloader and `/boot` partition
2. **SSD in ODD Port**: Contains ZFS root filesystem
3. **BIOS Settings**: AHCI mode enabled for proper SATA performance
4. **Boot Sequence**: SD card → GRUB → ZFS root on SSD

### Device Layout
- **SD Card**: `/dev/disk/by-id/usb-HP_iLO_Internal_SD-CARD_*` (8-32GB recommended)
- **System SSD**: `/dev/disk/by-id/ata-WDC_WDS500G1R0A-*` (500GB, ODD port)
- **Storage Drives**: 4x4TB SATA drives in internal bays

### BIOS Configuration
Required BIOS settings for this setup:
- **SATA Controller**: AHCI mode (not IDE/Legacy)
- **Boot Mode**: Legacy BIOS (not UEFI)
- **Boot Priority**: Internal SD card first, then SSD
- **Advanced → System Options → SATA Controller**: Enable AHCI

## Memory Management

### ZFS ARC Limits
ZFS ARC is limited to prevent memory starvation in KVM hypervisor environment:
- Maximum ARC: 4GB (25% of total RAM)
- Minimum ARC: 1GB
- Configuration: `boot.extraModprobeConfig` with ZFS kernel module parameters

### Memory Allocation
- ZFS ARC: 4GB maximum
- zram: 4GB (25% of total RAM)
- Available for KVM/system: ~8GB

## Storage Access

### Group Management
- **nas-users**: Custom group (GID 1000) for NAS dataset access
- **storage**: System group for storage device access

### Dataset Permissions
All storage datasets (`/mnt/app_config`, `/mnt/media`, `/mnt/backup`) are configured with:
- Owner: `root:nas-users`
- Permissions: `2775` (group sticky bit, read-write for group)
- Automatic permission setup via `nas-storage-permissions` systemd service

## Samba Configuration

### Service Setup
Samba is configured for secure local network file sharing:
- Workgroup: `WORKGROUP`
- NetBIOS name: `nas`
- Protocol: SMB2 minimum
- Security: User-based authentication

### Network Access
- **Allowed networks**: 192.168.x.x, 10.x.x.x, 127.x.x.x
- **Denied**: All other networks (internet access blocked)
- **Firewall ports**: 445 (SMB), 137/138 (NetBIOS)

### Shares
Three shares are configured corresponding to storage datasets:

| Share Name | Path | Access | Description |
|------------|------|--------|-------------|
| `media` | `/mnt/media` | nas-users group | Media files and content |
| `backup` | `/mnt/backup` | nas-users group | Backup storage |
| `app_config` | `/mnt/app_config` | nas-users group | Application configurations |

### User Management
Two types of users have access:

1. **Service User**: `nas-user`
   - System user (no home directory, no shell login)
   - Primary group: `nas-users`
   - Extra groups: `storage`
   - Purpose: Dedicated Samba service account

2. **Admin User**: Your main user account
   - Full system access with sudo
   - Groups: `wheel`, `networkmanager`, `storage`, `nas-users`
   - SSH key authentication enabled

## Installation Notes

### Initial Installation Process
For HP MicroServer Gen8 systems, follow this specific installation sequence:

1. **BIOS Setup**: Start in IDE/Legacy mode for initial installation
2. **Install NixOS**: Use standard installation to SSD in ODD port
3. **SD Card Preparation**: Insert 8-32GB SD card in internal slot
4. **Manual GRUB Setup**: Install GRUB bootloader to SD card
5. **Configuration Update**: Update NixOS config for AHCI mode
6. **BIOS Transition**: Switch to AHCI mode and test boot

### Manual GRUB Installation
After initial NixOS installation, prepare the SD card:

```bash
# Partition and format SD card
sudo fdisk /dev/disk/by-id/usb-HP_iLO_Internal_SD-CARD_*:0
# Create primary partition, mark bootable

sudo mkfs.ext4 /dev/disk/by-id/usb-HP_iLO_Internal_SD-CARD_*:0-part1

# Install GRUB to SD card
sudo mkdir -p /mnt/sdboot
sudo mount /dev/disk/by-id/usb-HP_iLO_Internal_SD-CARD_*:0-part1 /mnt/sdboot
sudo grub-install --target=i386-pc --boot-directory=/mnt/sdboot /dev/disk/by-id/usb-HP_iLO_Internal_SD-CARD_*:0
sudo grub-mkconfig -o /mnt/sdboot/grub/grub.cfg
```

### AHCI Transition Checklist
1. ✅ SD card prepared with GRUB bootloader
2. ✅ NixOS config updated with AHCI kernel modules
3. ✅ Boot device changed to SD card in configuration
4. ✅ System rebuilt with new configuration
5. ✅ BIOS switched to AHCI mode
6. ✅ Boot priority set: SD card first

## Post-Deployment Setup

### Samba Password Configuration
After initial deployment, set passwords for Samba users:

```bash
# Set password for service user
sudo smbpasswd -a nas-user

# Set password for admin user
sudo smbpasswd -a <username>
```

### Accessing Shares
From Windows: `\\nas\media`, `\\nas\backup`, `\\nas\app_config`
From macOS: `smb://nas/media`, `smb://nas/backup`, `smb://nas/app_config`
From Linux: `smb://nas/media` or mount via `/etc/fstab`

## Maintenance

### ZFS Health Monitoring
```bash
# Check pool status
sudo zpool status

# Check dataset usage
sudo zfs list

# Scrub pools (recommended monthly)
sudo zpool scrub rpool
sudo zpool scrub storage
```

### Samba Management
```bash
# List Samba users
sudo pdbedit -L

# Check Samba status
sudo systemctl status samba-smbd

# View active connections
sudo smbstatus
```

### Performance Monitoring
```bash
# Monitor I/O
iotop

# Check disk usage
ncdu /mnt/media
ncdu /mnt/backup
ncdu /mnt/app_config

# Memory usage
htop
```

## Troubleshooting

### Boot Issues

**Problem**: System won't boot after AHCI switch
**Solutions**:
1. Check BIOS boot priority - SD card must be first
2. Verify SD card is properly detected in BIOS
3. Test GRUB installation: boot from SD card manually
4. Check ZFS pool import - may need `zpool import -f rpool`

**Problem**: GRUB installation fails with "cannot find GRUB drive"
**Solutions**:
1. Verify device path: `ls /dev/disk/by-id/usb-HP_iLO_Internal_SD-CARD_*`
2. Check for trailing colons in device path
3. Ensure SD card is properly partitioned and formatted
4. Try alternative device path: `/dev/mmcblk0` or `/dev/sdf`

**Problem**: ZFS pools not importing after AHCI switch
**Solutions**:
1. Check device names changed: `zpool status`
2. Import pools manually: `sudo zpool import -f storage`
3. Update `/etc/zfs/zpool.cache` if needed
4. Verify AHCI kernel modules loaded: `lsmod | grep ahci`

### Performance Issues

**Problem**: Poor disk performance
**Solutions**:
1. Verify AHCI mode enabled in BIOS
2. Check write caching: `sudo hdparm -W /dev/sd*`
3. Monitor I/O: `iotop`, `iostat -x 1`
4. Check ZFS ARC usage: `arc_summary`

**Problem**: High memory usage
**Solutions**:
1. Check ZFS ARC limit: `cat /sys/module/zfs/parameters/zfs_arc_max`
2. Monitor memory: `free -h`, `btop`
3. Verify zram configuration: `zramctl`

### Network/Samba Issues

**Problem**: Samba shares not accessible
**Solutions**:
1. Check service status: `sudo systemctl status samba-smbd`
2. Verify firewall ports: `sudo ss -tlnp | grep :445`
3. Test local access: `smbclient -L localhost`
4. Check user database: `sudo pdbedit -L`

**Problem**: Permission denied on shares
**Solutions**:
1. Verify dataset permissions: `ls -la /mnt/media`
2. Check user groups: `groups <username>`
3. Test with: `sudo chmod 2775 /mnt/media`
4. Verify Samba user exists: `sudo smbpasswd -a <username>`

## Network Services

### Enabled Ports
- **22**: SSH (key-based authentication)
- **80/443**: HTTP/HTTPS (for future web services)
- **445**: SMB file sharing
- **137/138**: NetBIOS services
- **2049**: NFS (reserved for future use)
- **8080**: Alternative web UI port
- **9090**: Cockpit web console

## Security Notes

- Root login via SSH is disabled
- Password authentication is disabled (SSH keys only)
- Samba access restricted to private networks
- Storage datasets have group-based access control
- Regular security updates via NixOS channels