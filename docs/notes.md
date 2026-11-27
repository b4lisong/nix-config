# Machine Setup Instructions

## Setting Up a Machine That Already Has a Host Configuration

Use `scripts/bootstrap.sh <host>`. It detects whether the machine is macOS
or NixOS and its architecture, refuses to continue if `<host>` is defined
for a different architecture in `outputs/<arch>/src/`, and runs the first
activation. Each step is skipped if already done, so re-run it after fixing
a failure.

On a fresh machine with no checkout, pipe it from GitHub. It clones the repo
to `~/dev/nix-config` over HTTPS and continues from there:

```bash
curl -fsSL https://raw.githubusercontent.com/b4lisong/nix-config/main/scripts/bootstrap.sh | bash -s -- <host>
```

From an existing checkout:

```bash
scripts/bootstrap.sh <host>            # run it
scripts/bootstrap.sh --dry-run <host>  # print what would change
scripts/bootstrap.sh --help            # options and the list of hosts
```

### What it does

**macOS (nix-darwin)**

1. Installs upstream Nix with the Determinate Systems installer
   (`--prefer-upstream-nix`) if `nix` is missing.
2. Installs Homebrew if the host enables `homebrew` (nix-darwin manages
   Homebrew packages but does not install Homebrew).
3. Sets `HostName` and `LocalHostName` to `<host>`, since `just` targets
   `.#$(hostname -s)`.
4. Moves `/etc/bashrc`, `/etc/zshrc` and `/etc/zshenv` to
   `*.before-nix-darwin` (restored if activation fails), then runs
   `darwin-rebuild switch` using the nix-darwin version pinned in
   `flake.lock`.

**NixOS, already installed**

1. If the host has a `hardware-configuration.nix`, compares it with
   `nixos-generate-config --show-hardware-config` and offers to replace it
   (default: keep).
2. Runs `nixos-rebuild switch --flake .#<host>`.

**NixOS, fresh install from the installer ISO (`--install`)**

Requires `hosts/linux-<host>/disks.nix`. Boot the NixOS ISO, then:

```bash
curl -fsSL https://raw.githubusercontent.com/b4lisong/nix-config/main/scripts/bootstrap.sh | bash -s -- --install <host>
```

1. Lists the disks named in `disks.nix` and asks you to type the host name
   to confirm. **Everything on those disks is erased.** `--yes` does not skip
   this.
2. Partitions, formats and mounts them with disko.
3. Regenerates `hardware-configuration.nix` from `/mnt` and offers to replace
   it (default: replace). Filesystems are mounted by UUID, and formatting
   creates new UUIDs, so keeping the old file produces a system that does
   not boot.
4. Runs `nixos-install --flake .#<host>`, which asks for a root password.
5. Copies the repo to `~/dev/nix-config` in the new system.

Remove the installer media and reboot.

### Afterwards

- If `hardware-configuration.nix` changed, review and commit it.
- The clone uses HTTPS. To push, switch to SSH:
  `git remote set-url origin git@github.com:b4lisong/nix-config.git`
- Day-to-day rebuilds: `just check`, `just rebuild`.

## Adding a New Host to the Configuration

Follow [hosts/README.md](../hosts/README.md) to create
`hosts/<platform>-<name>/`, `outputs/<arch>/src/<name>.nix`, and an entry in
`variables/default.nix`. Hosts are discovered automatically, so `flake.nix`
does not change. `git add` the new files, run `nix flake check`, then
bootstrap the machine as above.

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