# Disko Configuration Guide: NAS with RAIDZ10 Storage

This document explains the `disks.nix` configuration for a bare-metal NAS deployment using Disko, NixOS's declarative disk partitioning tool. It serves as both documentation for this specific setup and an educational guide for understanding Disko concepts.

## Table of Contents

- [Overview](#overview)
- [Hardware Layout](#hardware-layout)
- [Disko Concepts](#disko-concepts)
- [Configuration Walkthrough](#configuration-walkthrough)
- [Technical Deep Dives](#technical-deep-dives)
- [Usage and Deployment](#usage-and-deployment)
- [Troubleshooting](#troubleshooting)
- [Customization Guide](#customization-guide)

## Overview

### What is Disko?

Disko is a declarative disk partitioning and formatting tool for NixOS. Instead of manually partitioning disks with `fdisk` or `parted`, you describe your desired disk layout in a Nix configuration file, and Disko handles the entire process automatically.

**Key Benefits:**
- **Reproducible**: Same configuration produces identical disk layouts
- **Declarative**: Describe what you want, not how to achieve it
- **Version Controlled**: Disk layouts become part of your NixOS configuration
- **Automated**: No manual partitioning or filesystem creation required

### This Configuration

This setup creates a professional NAS server with:
- **Legacy BIOS boot** for older hardware compatibility
- **ZFS root filesystem** with organized datasets
- **RAIDZ10 storage array** for high performance and redundancy
- **Stable disk identification** to prevent hardware mix-ups

## Hardware Layout

### Physical Hardware
```
┌─────────────────┐  ┌─────────────────┐
│   System SSD    │  │  Storage Array  │
│    (500GB)      │  │     (4x4TB)     │
│                 │  │                 │
│ /dev/sde        │  │ /dev/sd{a,b,c,d}│
│ WD Red SSD      │  │ 3x Seagate +    │
│                 │  │ 1x Hitachi      │
└─────────────────┘  └─────────────────┘
```

### Logical Layout
```
System SSD (/dev/sde):
├── BIOS Boot (1MB)     - EF02 partition for legacy GRUB
├── /boot (512MB)       - ext4 boot partition
└── ZFS Pool "rpool"    - Root filesystem with datasets

Storage Array (4 disks):
└── ZFS Pool "storage"  - RAIDZ10 (mirror of two RAIDZ1 vdevs)
    ├── vdev1: RAIDZ1   - /dev/sda + /dev/sdb
    └── vdev2: RAIDZ1   - /dev/sdc + /dev/sdd
```

## Disko Concepts

### Core Structure

Every Disko configuration follows this hierarchy:

```nix
disko.devices = {
  disk = {
    # Physical disk definitions
    diskName = {
      type = "disk";
      device = "/dev/disk/by-id/...";  # Stable identifier
      content = {
        # Partitioning and content definition
      };
    };
  };

  zpool = {
    # ZFS pool definitions
    poolName = {
      type = "zpool";
      # Pool configuration, topology, datasets
    };
  };
};
```

### Key Concepts

**Disks**: Physical storage devices that get partitioned and formatted
**Pools**: ZFS storage pools that aggregate disk space across multiple devices
**vdevs**: Virtual devices that define redundancy (mirror, raidz1, raidz2)
**Datasets**: ZFS filesystems within pools, similar to traditional partitions

## Configuration Walkthrough

### 1. Stable Disk Identification

```nix
device = "/dev/disk/by-id/ata-WDC_WDS500G1R0A-68A4W0_2041DA803271";
```

**Why stable identifiers?**
- Device names like `/dev/sda` can change between boots
- Hardware IDs are permanent and tied to the physical drive
- Prevents accidentally formatting the wrong disk

**Finding your disk IDs:**
```bash
ls -l /dev/disk/by-id/ | grep -E "(sda|sdb|sdc|sdd|sde)"
```

### 2. System Disk Configuration

```nix
sde = {
  type = "disk";
  device = "/dev/disk/by-id/ata-WDC_WDS500G1R0A-68A4W0_2041DA803271";
  content = {
    type = "gpt";                    # Modern partition table
    partitions = {
      bios = {
        size = "1M";
        type = "EF02";               # BIOS boot partition
      };
      boot = {
        size = "512M";
        content = {
          type = "filesystem";
          format = "ext4";           # Reliable boot filesystem
          mountpoint = "/boot";
          mountOptions = ["defaults" "noatime"];
        };
      };
      zfs = {
        size = "100%";               # Remaining space
        content = {
          type = "zfs";
          pool = "rpool";            # Links to ZFS pool definition
        };
      };
    };
  };
};
```

**Key Points:**
- **EF02**: BIOS boot partition type for legacy GRUB
- **Separate /boot**: ext4 is more universally supported than ZFS for booting
- **noatime**: Performance optimization for boot partition

### 3. Storage Disk Configuration

```nix
sda = {
  type = "disk";
  device = "/dev/disk/by-id/ata-ST4000VN006-3CW104_ZW6034KJ";
  content = {
    type = "gpt";
    partitions = {
      zfs = {
        size = "100%";               # Single partition for entire disk
        content = {
          type = "zfs";
          pool = "storage";          # Links to storage pool
        };
      };
    };
  };
};
```

**Design Choice: Why Partitioned?**
- **Disko Compatibility**: Works reliably with topology references
- **Future Flexibility**: Can add small utility partitions later
- **Standard Practice**: Most enterprise ZFS deployments use partitions
- **Alignment**: GPT ensures proper 4K sector alignment

### 4. ZFS Root Pool (rpool)

```nix
rpool = {
  type = "zpool";
  rootFsOptions = {
    compression = "lz4";             # Fast compression algorithm
    "com.sun:auto-snapshot" = "false"; # Disable automatic snapshots
  };
  options = {
    compatibility = "grub2";         # Enable legacy boot support
  };
  datasets = {
    root = {
      type = "zfs_fs";
      mountpoint = "/";
      options.mountpoint = "legacy"; # Required for NixOS integration
    };
    nix = {
      type = "zfs_fs";
      mountpoint = "/nix";
      options.mountpoint = "legacy";
    };
    # ... more datasets
  };
};
```

**Dataset Organization Benefits:**
- **Separation of Concerns**: Different areas can have different properties
- **Snapshot Granularity**: Snapshot `/home` without including `/nix`
- **Performance Tuning**: Different recordsize for different workloads
- **Quota Management**: Set space limits per dataset if needed

### 5. RAIDZ10 Storage Pool

```nix
storage = {
  type = "zpool";
  mode = {
    topology = {
      type = "topology";
      vdev = [
        {
          mode = "raidz1";           # First RAIDZ1 vdev
          members = ["sda" "sdb"];   # References disk names
        },
        {
          mode = "raidz1";           # Second RAIDZ1 vdev
          members = ["sdc" "sdd"];
        }
      ];
    };
  };
  # Pool options and datasets...
};
```

**RAIDZ10 Explained:**
- **Two RAIDZ1 vdevs**: Each can lose 1 disk and continue operating
- **Striped together**: Data is striped across both vdevs for performance
- **Can survive**: Loss of entire vdev (2 disks) as long as it's the same vdev
- **Performance**: Better than single RAIDZ1, not as fast as mirrors

## Technical Deep Dives

### Legacy Boot vs UEFI

**Why Legacy Boot?**
- Older hardware may not support UEFI
- Simpler boot process for servers
- GRUB2 compatibility with ZFS

**Requirements:**
```nix
bios = {
  size = "1M";
  type = "EF02";  # BIOS boot partition
};
```

**GRUB Configuration:**
```nix
options = {
  compatibility = "grub2";  # Enable features GRUB can handle
};
```

### ZFS Compression

**lz4 Choice:**
- **Fast**: Often faster than no compression due to reduced I/O
- **Universal**: Works well with all data types
- **CPU Efficient**: Minimal CPU overhead
- **Reliable**: Well-tested and stable

**Alternative Options:**
- `zstd`: Better compression ratio, more CPU usage
- `gzip`: Legacy option, slower than lz4
- `off`: No compression, maximum performance for incompressible data

### Auto-Snapshots Disabled

```nix
"com.sun:auto-snapshot" = "false";
```

**Reasons:**
- **Performance**: Avoid periodic I/O spikes
- **Storage Management**: Prevent uncontrolled space usage
- **Custom Control**: Implement application-specific backup strategies
- **NixOS Integration**: System generations provide OS-level versioning

### Legacy Mountpoints

```nix
options.mountpoint = "legacy";
```

**Why Required:**
- **NixOS Integration**: Required for proper boot process
- **fstab Management**: NixOS manages mounting through traditional methods
- **Compatibility**: Works with existing NixOS tooling and scripts

## Usage and Deployment

### Prerequisites

1. **NixOS Live Environment**: Boot from NixOS installer
2. **Hardware Access**: Physical or IPMI access to target machine
3. **Backup**: Ensure any existing data is backed up (this will destroy everything)

### Deployment Command

```bash
# Add the configuration to git (Nix flakes only see tracked files)
git add hosts/linux-nas/disks.nix

# Run Disko to partition and format disks
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  hosts/linux-nas/disks.nix
```

### Post-Deployment Verification

```bash
# Check pool status
zpool status

# Verify datasets
zfs list

# Check mount points
mount | grep zfs

# Verify boot partition
ls -la /mnt/boot
```

## Troubleshooting

### Common Issues

**1. Pool Import Fails**
```
cannot import 'storage': no such pool available
```
**Solution**: Check if disks are properly connected and detected:
```bash
lsblk -f
ls -l /dev/disk/by-id/
```

**2. Topology Error**
```
not all disks accounted for, skipping creating zpool
```
**Solution**: Verify all disk references match between disk definitions and topology members.

**3. Legacy Boot Issues**
```
GRUB installation failed
```
**Solution**: Ensure BIOS boot partition (EF02) exists and compatibility="grub2" is set.

### Verification Commands

```bash
# Check Disko configuration syntax
nix-instantiate --eval --expr 'import hosts/linux-nas/disks.nix'

# Verify hardware matches configuration
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT

# Test ZFS functionality
zpool scrub storage
zfs snapshot storage@test
zfs list -t snapshot
```

## Customization Guide

### Different Hardware

**1. Update Disk IDs**
```bash
# Find your disk IDs
ls -l /dev/disk/by-id/ | grep -v part

# Replace in configuration
device = "/dev/disk/by-id/your-actual-disk-id";
```

**2. Different Disk Count**
For 6 disks in RAIDZ2 configuration:
```nix
vdev = [
  {
    mode = "raidz2";
    members = ["sda" "sdb" "sdc" "sdd" "sde" "sdf"];
  }
];
```

**3. UEFI Boot**
Replace BIOS partition with ESP:
```nix
ESP = {
  size = "512M";
  type = "EF00";
  content = {
    type = "filesystem";
    format = "vfat";
    mountpoint = "/boot";
  };
};
```

### Performance Tuning

**1. Different Compression**
```nix
rootFsOptions = {
  compression = "zstd";     # Better compression
  # or
  compression = "off";      # No compression for maximum speed
};
```

**2. Dataset-Specific Options**
```nix
media = {
  type = "zfs_fs";
  mountpoint = "/mnt/media";
  options = {
    mountpoint = "legacy";
    compression = "off";      # Media files don't compress well
    recordsize = "1M";        # Larger record size for large files
  };
};
```

### Alternative Layouts

**Simple Mirror (2 disks):**
```nix
mode = "mirror";
members = ["sda" "sdb"];
```

**RAIDZ2 (5+ disks):**
```nix
vdev = [
  {
    mode = "raidz2";
    members = ["sda" "sdb" "sdc" "sdd" "sde"];
  }
];
```

---

*This configuration has been tested and deployed successfully. For questions or improvements, consult the [Disko documentation](https://github.com/nix-community/disko) or the NixOS community.*