# NAS Configuration

This document describes the NAS server configuration and setup procedures.

## System Overview

### Hardware Configuration
- **System Storage**: 500GB SSD with ZFS root pool (`rpool`)
- **Data Storage**: 4x4TB drives in RAIDZ10 configuration (`storage` pool)
- **Memory**: 16GB RAM with ZFS ARC limited to 4GB
- **Architecture**: x86_64 with Intel KVM support

### ZFS Pools
- **rpool**: System pool on SSD with datasets for `/`, `/nix`, `/var`, `/home`, `/incus`
- **storage**: Data pool with datasets for `/mnt/app_config`, `/mnt/media`, `/mnt/backup`

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