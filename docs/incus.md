# HomeAssistant VM Implementation Plan using Incus

This document outlines the implementation plan for running a HomeAssistant VM on the linux-nas host using Incus virtualization.

## System Overview

### Current Environment Analysis
- **Host**: HP MicroServer Gen8 with 16GB RAM, x86_64 architecture
- **Storage**: ZFS root pool (`rpool`) on 500GB SSD + ZFS data pool (`storage`) on 4x4TB RAIDZ10
- **Memory**: ZFS ARC limited to 4GB, zram 4GB, leaving ~8GB available for VMs
- **Virtualization**: KVM-Intel support enabled in kernel modules
- **Network**: NetworkManager configured with firewall rules for various services
- **Existing Services**: Samba shares, SSH, basic NAS functionality

### Incus Integration Points
- **Storage**: Dedicated `/incus` ZFS dataset already configured in `rpool/incus`
- **Memory**: Sufficient RAM available for VM allocation (recommended 2-4GB for HomeAssistant)
- **CPU**: Intel KVM support already enabled
- **Network**: Existing firewall can be extended for HomeAssistant ports

## Implementation Plan

### Phase 1: Incus Installation and Configuration

#### 1.1 Enable Incus in NixOS Configuration
**File**: `/hosts/linux-nas/default.nix`

Add Incus virtualization configuration:
```nix
virtualisation.incus = {
  enable = true;
  ui.enable = true;  # Enable Incus web UI
  preseed = {
    networks = [
      {
        name = "incusbr0";
        type = "bridge";
        config = {
          "ipv4.address" = "10.0.100.1/24";
          "ipv4.nat" = "true";
        };
      }
    ];
    storage_pools = [
      {
        name = "zfs-incus";
        driver = "zfs";
        config = {
          source = "rpool/incus";
        };
      }
    ];
    profiles = [
      {
        name = "default";
        devices = {
          eth0 = {
            name = "eth0";
            network = "incusbr0";
            type = "nic";
          };
          root = {
            path = "/";
            pool = "zfs-incus";
            type = "disk";
          };
        };
      }
    ];
  };
};

# Required for Incus networking
networking.nftables.enable = true;
```

#### 1.2 User Access Configuration
Add user to incus-admin group:
```nix
users.users.${myvars.user.username} = {
  extraGroups = [
    # ... existing groups ...
    "incus-admin" # Access to Incus management
  ];
};
```

#### 1.3 Firewall Configuration
For simplicity, disable the firewall (local network only):
```nix
# Disable firewall for simplified setup
networking.firewall.enable = false;
```

**Note**: This assumes the system is on a trusted local network. For production use, consider enabling specific port rules instead.

### Phase 2: HomeAssistant VM Preparation

#### 2.1 VM Specifications
Based on HomeAssistant requirements and available resources:
- **CPU**: 2 vCPUs (sufficient for typical HA workload)
- **Memory**: 4GB RAM (allows for multiple add-ons)
- **Disk**: 32GB (expandable as needed)
- **Network**: Bridge to host network for device discovery

#### 2.2 VM Image Selection
**Using Official HomeAssistant OS VM Appliance**: Pre-configured appliance with all components integrated.

This approach provides:
- Complete HomeAssistant OS with Supervisor
- Built-in add-on management
- Automatic updates and maintenance
- Optimized for HomeAssistant workloads

### Phase 3: VM Creation and Deployment

#### 3.1 Download HomeAssistant OS Image
Download the official HomeAssistant OS VM image:
```bash
# Initialize Incus (if not done via preseed)
sudo incus admin init --auto

# Download HomeAssistant OS VM image (latest version)
# Get the latest version from https://github.com/home-assistant/operating-system/releases
HAOS_VERSION="13.2"  # Update to latest version
wget "https://github.com/home-assistant/operating-system/releases/download/${HAOS_VERSION}/haos_generic-x86-64-${HAOS_VERSION}.qcow2.xz"

# Extract the image
xz -d "haos_generic-x86-64-${HAOS_VERSION}.qcow2.xz"
```

#### 3.2 Import and Configure HomeAssistant VM
```bash
# Import the HomeAssistant OS image
incus image import "haos_generic-x86-64-${HAOS_VERSION}.qcow2" --alias homeassistant-os

# Create VM from HomeAssistant OS image
incus launch homeassistant-os homeassistant --vm \
  --config limits.cpu=2 \
  --config limits.memory=4GB \
  --config limits.disk=32GB

# Configure VM for optimal performance
incus config set homeassistant boot.autostart=true
incus config set homeassistant security.secureboot=false

# Start the VM
incus start homeassistant

# Wait for HomeAssistant to boot (can take 5-10 minutes on first boot)
echo "HomeAssistant is starting up... This may take several minutes."
echo "Access the web interface at: http://$(incus list homeassistant -c4 --format csv | cut -d' ' -f1):8123"
```

#### 3.3 HomeAssistant Initial Setup
After the VM starts:
1. **Wait for boot**: HomeAssistant OS takes 5-10 minutes to fully initialize on first boot
2. **Access web interface**: Navigate to `http://<vm-ip>:8123` in your browser
3. **Complete setup wizard**: Create admin user and configure basic settings
4. **Install add-ons**: Use the built-in Supervisor for add-on management

### Phase 4: Network and Storage Integration

#### 4.1 Network Configuration

**Two Network Options Available:**

1. **NAT Network (`incusbr0`)**: Default - containers get 10.0.100.x addresses with NAT
2. **Bridged Network (`br0`)**: Containers get IP addresses directly from your router

**Using Bridged Network for HomeAssistant VM:**

The NixOS configuration automatically creates a `br0` bridge with your ethernet interface. After deployment:

```bash
# SSH to linux-nas host
ssh linux-nas

# 1. Create bridged profile that uses host br0 bridge directly
incus profile create bridged

# 2. Add network device connected directly to host bridge
incus profile device add bridged eth0 nic \
  nictype=bridged \
  parent=br0 \
  name=eth0

# 3. Add root disk device
incus profile device add bridged root disk \
  pool=zfs-incus \
  path=/

# 4. Create HomeAssistant VM with bridged network
incus launch homeassistant-os homeassistant --vm \
  --config limits.cpu=2 \
  --config limits.memory=4GB \
  --config limits.disk=32GB \
  --profile bridged
```

**Note**: The `br0` bridge is automatically created and managed by NixOS, getting an IP via DHCP. This is much simpler than manual NetworkManager configuration.

#### 4.2 Storage Integration
Options for persistent data:
1. **VM Internal Storage**: Keep config within VM (simplest)
2. **Host Mount**: Mount NAS directories into VM for backups
3. **Network Storage**: Use NFS/SMB from VM to NAS shares

**Recommended**: Start with option 1, add option 2 for backup integration.


## Implementation Checklist

### Pre-Implementation
- [ ] Verify sufficient memory available (check current usage)
- [ ] Confirm ZFS pool health and space
- [ ] Review network configuration and available IPs
- [ ] Plan maintenance window for initial setup

### Configuration Changes
- [ ] Add Incus configuration to `linux-nas/default.nix`
- [ ] Configure user access and permissions
- [ ] Update firewall rules
- [ ] Add monitoring and backup services
- [ ] Test NixOS configuration with `nixos-rebuild test`

### VM Deployment
- [ ] Initialize Incus with preseed configuration
- [ ] Create HomeAssistant VM with specified resources
- [ ] Install and configure HomeAssistant
- [ ] Test network connectivity and port access

## Resource Requirements

### Host Impact
- **CPU**: Minimal impact, 2 cores dedicated to VM
- **Memory**: 4GB dedicated to VM (50% of available VM memory)
- **Storage**: ~32GB initial, expandable from ZFS pool
- **Network**: Additional bridge interface, minimal impact

### VM Resources
- **CPU**: 2 vCPUs (adjustable)
- **Memory**: 4GB RAM (adjustable)
- **Disk**: 32GB root disk (expandable)
- **Network**: Bridged to host network

## Risk Assessment and Mitigation

### Risks
1. **Memory pressure**: VM memory usage affecting ZFS ARC
2. **Storage exhaustion**: VM disk growth impacting system pool
3. **Network conflicts**: Bridge configuration affecting host networking
4. **Service conflicts**: Port conflicts with existing NAS services

### Mitigations
1. Monitor memory usage, adjust VM limits or ZFS ARC as needed
2. Set disk quotas, monitor usage, plan storage expansion
3. Use separate network bridge, careful IP range selection
4. Use non-conflicting ports, document all port usage

## Success Criteria

### Functional Requirements
- HomeAssistant VM boots and runs reliably
- Web interface accessible from local network
- Device discovery and integration functional
- Backup and restore procedures verified

### Performance Requirements
- VM startup time < 2 minutes
- Web interface response time < 2 seconds
- Host system remains responsive during VM operation
- NAS services unaffected by VM operation

