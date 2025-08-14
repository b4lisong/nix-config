# Embedded Development Role

The embedded role provides tools and configurations specifically designed for hardware development, IoT projects, and embedded systems programming. This role is particularly useful for Raspberry Pi deployments, but works on any Linux system with hardware interfaces.

## Key Features

### Hardware Communication Tools
- **Serial Communication**: `minicom`, `picocom` for UART/serial debugging
- **I2C Interface**: `i2c-tools` for sensor communication and device scanning
- **GPIO Access**: User automatically added to hardware access groups

### System Monitoring for Embedded Systems  
- **Resource Monitoring**: `iotop`, `bandwhich`, `procs` optimized for constrained environments
- **Network Analysis**: `nmap`, `netcat-gnu`, `tcpdump` for embedded networking
- **Hardware Analysis**: `lshw`, `dmidecode`, `lsof` for hardware debugging

### Development Tools
- **Cross-Compilation**: `gcc`, `binutils` for embedded target development
- **Debugging**: `gdb`, `strace` for system-level debugging
- **Hardware Projects**: Latest `python3` for GPIO scripting and sensor interfaces

### Embedded-Specific Shell Configuration

**Hardware Monitoring Aliases:**
```bash
hw-temp        # Show temperature sensors across any Linux system
hw-freq        # Display CPU frequency information  
hw-info        # Complete hardware summary (CPU, memory, storage)
```

**GPIO and Hardware Interface:**
```bash
gpio-read      # Read GPIO state (when GPIO tools available)
i2c-scan       # Scan I2C bus for connected devices
```

**Network and System Utilities:**
```bash
net-scan       # Scan local network for devices
ports          # Show listening network ports
mem-usage      # Memory utilization
disk-usage     # Storage utilization
logs-errors    # Recent system errors
usb-tree       # USB device tree
```

### SSH Configuration for Embedded Deployment
- Optimized for embedded device management patterns
- Common IoT device hostname patterns (`.local`, private IP ranges)
- Keep-alive settings for NAT traversal
- Compression enabled for bandwidth-constrained connections

### Git Configuration for Hardware Projects
- Git LFS enabled for binary assets (firmware, images, PCB files)
- Embedded-specific `.gitignore` patterns:
  - Build artifacts (`*.o`, `*.elf`, `*.bin`, `*.hex`)
  - Hardware design files (`*.pcb-bak`, `*.sch-bak`)
  - IDE and log files

### Tmux Integration for Remote Hardware Work
- Serial communication shortcuts (`<prefix>S` opens minicom)
- Hardware monitoring windows (`<prefix>H` for htop, `<prefix>I` for I2C scan)
- Session persistence for long-running embedded development sessions

## Usage Examples

### Basic Hardware Interfacing
```bash
# Scan for I2C devices
i2c-scan

# Monitor system resources
hw-info
mem-usage

# Connect to embedded device via serial
minicom
# or
picocom /dev/ttyUSB0 -b 115200
```

### Network Discovery and Debugging
```bash
# Find devices on local network
net-scan

# Check what services are running
ports

# Analyze network traffic
sudo tcpdump -i eth0
```

### Development Workflow
```bash
# Cross-compile for embedded target
gcc -static -o firmware main.c

# Debug embedded application
gdb firmware
# or trace system calls
strace ./firmware

# Version control with binary assets
git lfs track "*.bin"
git add firmware.bin
```

## Platform Compatibility

**Raspberry Pi Features:**
- Hardware groups: `gpio`, `i2c`, `spi` access
- Pi-specific command integration
- SD card optimization awareness

**Generic Linux Features:**
- Hardware monitoring works on any Linux system
- Network tools for embedded networking
- Cross-compilation capabilities
- Development tool chain

**Cross-Platform Features:**
- SSH configuration works on macOS and Linux
- Git configuration universal
- Shell aliases gracefully degrade when hardware unavailable

## Integration with Other Roles

**Commonly Combined With:**
- **`roles/dev`**: Full development environment with Neovim IDE
- **`roles/docker`**: Container support for embedded services
- **`profiles/tui`**: Terminal interface tools (btop, htop, etc.)
- **`profiles/base`**: Essential CLI tools and git configuration

**Example Combinations:**

**IoT Development Pi:**
```nix
imports = [
  ../../home/profiles/base
  ../../home/profiles/tui
  ../../home/roles/embedded
  ../../home/roles/dev
];
```

**Minimal Gateway Pi:**
```nix
imports = [
  ../../home/profiles/base
  ../../home/roles/embedded
  # Skip heavy development tools
];
```

**Security/Monitoring Pi:**
```nix
imports = [
  ../../home/profiles/base
  ../../home/roles/embedded
  ../../home/roles/security
];
```

## Quick Reference Helper

The role includes an `embedded-help` command that provides a quick reference:

```bash
embedded-help
```

This displays all available hardware commands, monitoring tools, and usage examples for the current system.

## Environment Variables

- `EMBEDDED_TOOLS_PATH`: Added to PATH for embedded development tools
- `PYTHONPATH`: Enhanced for hardware libraries (Pi-specific paths)

## Requirements

**Hardware Access:**
- User must be in appropriate groups (`gpio`, `i2c`, `spi`) for hardware access
- Hardware interfaces must be enabled in kernel/firmware configuration

**Network Tools:**
- Some network analysis tools require `sudo` privileges
- Serial interfaces require appropriate permissions (`dialout` group)

**Development Tools:**
- Cross-compilation may require additional target libraries
- Hardware debugging may require specific driver support

This role provides a comprehensive foundation for any embedded development workflow while remaining lightweight and adaptable to different hardware platforms and project requirements.