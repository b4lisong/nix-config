# Machine Setup Instructions

## For New Machines Using Existing Configuration

1. **Install Nix**
   ```bash
   curl -fsSL https://install.determinate.systems/nix | sh -s -- install
   ```
   - Choose 'no' when prompted to install the Determinate distribution to install the recommended vanilla upstream Nix.

2. **Clone Configuration Repository**
   ```bash
   git clone https://github.com/b4lisong/nix-config.git
   cd nix-config
   ```

3. **Check Available Machine Configurations**
   ```bash
   # View defined machines in variables/default.nix
   grep -A 5 "hosts = {" variables/default.nix
   ```

4. **Use Existing Machine Configuration**
   ```bash
   # For Darwin machines (a2251, sksm3):
   sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake .#<hostname>
   sudo darwin-rebuild switch --flake .#<hostname>
   
   # For NixOS machines (rpi4b):
   sudo nixos-rebuild switch --flake .#<hostname>
   
   # Or use Just commands (auto-detects platform):
   just rebuild
   just check
   
   # Examples:
   # sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake .#a2251
   # sudo darwin-rebuild switch --flake .#sksm3
   # sudo nixos-rebuild switch --flake .#rpi4b
   ```

## For Adding New Machines to Configuration

1. **Follow steps 1-2 above to install Nix and clone repository**

2. **Create new branch for machine setup**
   ```bash
   git checkout -b <new-hostname>
   git push -u origin <new-hostname>
   ```

3. **Add machine definition to variables/default.nix**
   ```nix
   <hostname> = {
     hostname = "<hostname>";
     system = "<architecture>"; # "aarch64-darwin" for Apple Silicon, "x86_64-darwin" for Intel
     description = "<description>";
   };
   ```

4. **Create host configuration files**
   ```bash
   mkdir hosts/<hostname>
   # Create hosts/<hostname>/system.nix (based on existing examples)
   # Create hosts/<hostname>/home.nix (based on existing examples)
   ```

5. **Add to flake.nix configurations**
   ```nix
   # For Darwin systems:
   darwinConfigurations.${vars.hosts.<hostname>.hostname} =
     nix-darwin.lib.darwinSystem (mkDarwinHost vars.hosts.<hostname>.hostname);
   
   # For NixOS systems:
   nixosConfigurations.${vars.hosts.<hostname>.hostname} =
     nixpkgs.lib.nixosSystem (mkNixOSHost vars.hosts.<hostname>.hostname);
   ```

6. **Test and apply configuration**
   ```bash
   git add .
   git commit -m "feat: add <hostname> machine configuration"
   nix flake check  # Verify configuration syntax
   
   # For Darwin systems:
   sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake .#<hostname>
   sudo darwin-rebuild switch --flake .#<hostname>
   
   # For NixOS systems:
   sudo nixos-rebuild switch --flake .#<hostname>
   
   # Or use Just commands:
   just check
   just rebuild
   ```

## Architecture Notes

- **Apple Silicon Macs**: Use `"aarch64-darwin"`
- **Intel Macs**: Use `"x86_64-darwin"`
- **Linux ARM**: Use `"aarch64-linux"` (fully supported)

## Current Defined Machines

- **a2251**: Personal MacBook Pro (Intel) - `x86_64-darwin` - Darwin configuration
- **sksm3**: Work MacBook (Apple Silicon) - `aarch64-darwin` - Darwin configuration
- **rpi4b**: Raspberry Pi 4B (ARM Linux) - `aarch64-linux` - NixOS configuration with embedded development environment

## Raspberry Pi 4B Setup Guide

### Prerequisites
- Raspberry Pi 4B (4GB+ RAM recommended)
- MicroSD card (32GB+ recommended)
- SSH key configured in `hosts/rpi4b/system.nix`

### Initial Deployment

1. **Build SD Card Image**
   ```bash
   # From a Darwin machine with aarch64-linux binfmt support:
   nix build .#nixosConfigurations.rpi4b.config.system.build.sdImage
   
   # Image will be created in result/sd-image/
   ```

2. **Flash to SD Card**
   ```bash
   # Find SD card device
   diskutil list
   
   # Flash image (replace /dev/diskX with your SD card)
   sudo dd if=result/sd-image/nixos-sd-image-*.img of=/dev/diskX bs=1M status=progress
   ```

3. **Initial Boot and Access**
   ```bash
   # Insert SD card into Pi and boot
   # Find Pi IP address (check router or use network scanner)
   ssh root@<pi-ip-address>
   
   # Or if using .local resolution:
   ssh root@rpi4b.local
   ```

4. **Deploy Configuration**
   ```bash
   # On the Pi (as root initially):
   nix-shell -p git --run "git clone https://github.com/b4lisong/nix-config.git"
   cd nix-config
   
   # Apply full configuration
   nixos-rebuild switch --flake .#rpi4b
   
   # Set user password
   passwd balisong
   
   # Disable root SSH (edit system.nix and rebuild)
   # Change PermitRootLogin from "yes" to "no"
   ```

### Post-Setup Configuration

**Hardware Access:**
- GPIO, I2C, SPI access via `/dev/gpiomem`, `/dev/i2c-1`, `/dev/spidev0.0`
- User automatically added to `gpio`, `i2c`, `spi` groups

**Embedded Development Tools:**
- Serial communication: `minicom`, `picocom`  
- Hardware interfacing: `i2c-tools`
- System monitoring: `iotop`, `bandwhich`, `htop`
- Development: `gcc`, `gdb`, `python3`

**Pi-Specific Aliases:**
```bash
temp          # Pi temperature monitoring
gpio-read     # GPIO state (if wiringPi available)
i2c-scan      # Scan I2C bus for devices
pi-info       # Pi system information
sd-health     # SD card health check
```

**Performance Optimizations:**
- SD card longevity (reduced swappiness, optimized write patterns)
- Automatic garbage collection
- Lightweight service configuration
- Resource-constrained Neovim setup

### Updating the Pi

```bash
# SSH to Pi
ssh balisong@rpi4b.local

# Update configuration
cd nix-config
git pull
sudo nixos-rebuild switch --flake .#rpi4b

# Or use Just commands
just rebuild
```

### Specialized Pi Configurations

The Pi configuration uses a modular architecture that enables easy customization:

**Base Hardware Module:** `modules/nixos/raspberry-pi.nix`
- Reusable across different Pi purposes
- Hardware optimization and driver support
- SD card longevity configurations

**Embedded Role:** `home/roles/embedded/`
- Hardware development tools
- Cross-platform embedded utilities
- Serial/I2C/GPIO interface tools

**Current Setup:** TUI + Dev + Embedded + Docker roles
- Headless operation optimized
- Full development environment
- Container support for services
- Hardware interfacing capabilities

**Creating Specialized Builds:**
```bash
# For IoT Gateway Pi:
# Remove dev role, add minimal networking
imports = [
  ../../home/profiles/base
  ../../home/profiles/tui  
  ../../home/roles/embedded
  # Skip heavy dev tools
];

# For DMZ Security Pi:
# Add security role, minimize attack surface
imports = [
  ../../home/profiles/base
  ../../home/roles/security
  ../../home/roles/embedded
];
```