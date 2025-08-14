/*
`home/roles/embedded/default.nix`
User environment for embedded systems and hardware development

This role provides tools and configurations specifically useful for:
- Raspberry Pi and single-board computer development
- IoT device programming and debugging
- Hardware interfacing (GPIO, I2C, SPI, UART)
- Embedded systems monitoring and troubleshooting
- Cross-platform development for ARM/embedded targets

Designed to complement the base and TUI profiles while adding
hardware-specific development capabilities. Can be used with
any system that has hardware development requirements.

Key focus areas:
- Hardware communication tools (serial, I2C, SPI)
- System monitoring for resource-constrained devices
- Network debugging tools for embedded networking
- Development utilities for hardware projects
- Performance monitoring tools suitable for embedded systems
*/
{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  # Embedded systems and hardware development packages
  home.packages = with pkgs; [
    # Hardware communication and interfacing
    minicom          # Serial terminal emulator
    picocom          # Minimal serial communication program
    i2c-tools        # I2C utilities for sensor interfacing
    spi-tools        # SPI utilities (if available)
    
    # System monitoring optimized for embedded systems
    iotop            # I/O monitoring (important for SD cards)
    bandwhich        # Network utilization monitoring per process
    procs            # Modern ps replacement with better embedded system info
    dust             # Disk usage analyzer (du replacement)
    
    # Network debugging and analysis
    nmap             # Network discovery and security auditing
    netcat-gnu       # Network debugging and data transfer
    tcpdump          # Network packet analyzer
    ethtool          # Ethernet interface configuration
    
    # Hardware analysis and debugging
    lshw             # Hardware information
    dmidecode        # DMI/SMBIOS table decoder
    lsof             # List open files (useful for hardware debugging)
    strace           # System call tracer
    
    # Development tools for embedded projects
    gcc              # C compiler for hardware projects
    gdb              # GNU debugger
    binutils         # Binary utilities (objdump, readelf, etc.)
    
    # File synchronization and remote access
    rsync            # Efficient file transfer and synchronization
    
    # Archive and compression tools
    p7zip            # 7-zip support
    unrar            # RAR extraction
    
    # Text processing for config files and logs
    jq               # JSON processor
    yq               # YAML processor
    
    # System utilities
    pciutils         # lspci for hardware enumeration
    usbutils         # lsusb for USB device info
    file             # File type detection
    which            # Command location utility
    tree             # Directory tree visualization
    
    # Git extensions for embedded development
    git-lfs          # Large file support for binary assets
  ] ++ [
    # Latest development tools for modern embedded projects
    pkgs-unstable.python3  # Latest Python for hardware scripting
  ];

  # Shell configuration for embedded development
  programs.zsh = {
    # Embedded systems specific aliases and functions
    shellAliases = {
      # Hardware monitoring shortcuts (works on any Linux system with /sys)
      "hw-temp" = "find /sys -name 'temp*_input' 2>/dev/null | head -5 | xargs -I {} sh -c 'echo -n \"{}: \"; cat {} 2>/dev/null | awk \"{print \\$1/1000 \\\"°C\\\"}'\" 2>/dev/null || echo 'Temperature sensors not available'";
      "hw-freq" = "cat /proc/cpuinfo | grep 'cpu MHz' || echo 'CPU frequency info not available'";
      
      # GPIO shortcuts (will work on Pi when available)
      "gpio-read" = "command -v gpio >/dev/null && gpio readall || echo 'GPIO tools not available'";
      
      # I2C detection
      "i2c-scan" = "command -v i2cdetect >/dev/null && i2cdetect -y 1 || echo 'I2C tools not available'";
      
      # Network diagnostics
      "net-scan" = "ip route | head -1 | awk '{print $3}' | xargs nmap -sn";
      "ports" = "ss -tuln";
      
      # System resource monitoring
      "mem-usage" = "free -h";
      "disk-usage" = "df -h | grep -E '^/dev/'";
      "top-processes" = "ps aux --sort=-%cpu | head";
      
      # Log analysis shortcuts
      "logs-errors" = "journalctl -p err -b";
      "logs-kernel" = "dmesg | tail -20";
      
      # Hardware information
      "hw-info" = "echo '=== CPU Info ==='; lscpu | head -10; echo; echo '=== Memory Info ==='; free -h; echo; echo '=== Storage Info ==='; lsblk";
      "usb-tree" = "lsusb -t";
    };
    
    # Environment variables for embedded development
    sessionVariables = {
      # Common embedded development paths
      EMBEDDED_TOOLS_PATH = "$HOME/.local/bin";
      # Python path for hardware libraries (Pi-specific but harmless elsewhere)
      PYTHONPATH = "$PYTHONPATH:/opt/vc/lib/python3.x/site-packages";
    };
  };

  # SSH configuration optimized for embedded device management
  programs.ssh = {
    # Host configurations for common embedded device patterns
    matchBlocks = {
      # Common embedded device hostnames
      "*.local" = {
        user = "pi";  # Common default for Pi devices
        forwardAgent = false;
        compression = true;
      };
      
      # IoT devices often use these IP ranges
      "192.168.*" = {
        forwardAgent = false;
        compression = true;
        serverAliveInterval = 30;  # Keep connections alive through NAT
        serverAliveCountMax = 3;
      };
      
      "10.*" = {
        forwardAgent = false;
        compression = true;
        serverAliveInterval = 30;
      };
    };
  };

  # Git configuration for embedded projects
  programs.git = {
    # Embedded development often involves binary files
    lfs.enable = true;
    
    # Common patterns for embedded development
    ignores = [
      # Build artifacts
      "*.o"
      "*.elf"
      "*.bin"
      "*.hex"
      
      # Embedded IDE files
      ".vscode/"
      "*.code-workspace"
      
      # Hardware-specific
      "*.pcb-bak"
      "*.sch-bak"
      
      # Logs and temporary files
      "*.log"
      "core.*"
    ];
  };

  # Tmux configuration optimized for embedded development
  programs.tmux = {
    extraConfig = ''
      # Embedded development often requires multiple serial connections
      bind-key S new-window -n "serial" "minicom"
      bind-key I new-window -n "i2c" "watch -n 2 i2cdetect -y 1"
      
      # Quick hardware monitoring windows
      bind-key H new-window -n "hardware" "htop"
      bind-key N new-window -n "network" "watch -n 2 'ss -tuln'"
      
      # Status bar with system info relevant to embedded systems
      set -g status-right "#[fg=green]#(uptime | cut -d',' -f3-) #[fg=yellow]#{?window_zoomed_flag, 🔍 ,}#[fg=blue]%Y-%m-%d %H:%M"
      
      # Automatic session restoration (useful for long-running embedded development)
      set -g @resurrect-save-bash-history 'on'
      set -g @resurrect-capture-pane-contents 'on'
    '';
  };

  # Development environment helpers
  home.file = {
    # Quick reference for common embedded commands
    ".local/bin/embedded-help" = {
      text = ''
        #!/usr/bin/env bash
        echo "=== Embedded Development Quick Reference ==="
        echo
        echo "Hardware Monitoring:"
        echo "  hw-temp     - Show temperature sensors"
        echo "  hw-freq     - Show CPU frequency"
        echo "  hw-info     - Complete hardware summary"
        echo
        echo "GPIO/I2C/SPI:"
        echo "  gpio-read   - Read all GPIO pins (Pi only)"
        echo "  i2c-scan    - Scan I2C bus for devices"
        echo
        echo "Network:"
        echo "  net-scan    - Scan local network"
        echo "  ports       - Show listening ports"
        echo
        echo "System:"
        echo "  logs-errors - Show system errors"
        echo "  top-processes - Show CPU-intensive processes"
        echo
        echo "Serial Communication:"
        echo "  minicom     - Serial terminal"
        echo "  picocom     - Lightweight serial terminal"
      '';
      executable = true;
    };
  };
}