/*
`modules/nixos/default.nix`
System-level configuration common to all NixOS hosts
Extends base system configuration in `modules/base.nix`

This module provides Linux-specific system configuration that applies
to all NixOS hosts, serving as the counterpart to `modules/darwin/default.nix`.
It focuses on essential NixOS system services, security, and optimization.
*/
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Add `~/.local/bin` to PATH for user-installed binaries
  environment.localBinInPath = true;

  # Nix configuration optimizations
  nix = {
    # Enable flakes and new nix command
    settings = {
      experimental-features = ["nix-command" "flakes"];
      
      # Binary cache configuration for faster builds
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimXuKWsyFQjy8Z8QK7k+j9YQjKtXHOM="
      ];
      
      # Optimize store and enable auto-optimise
      auto-optimise-store = true;
    };
    
    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Security configuration
  security = {
    # Enable AppArmor for additional security
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };
    
    # Configure polkit for privilege escalation
    polkit.enable = true;
    
    # Harden the system
    protectKernelImage = true;
  };

  # System services
  services = {
    # Log management
    journald = {
      extraConfig = ''
        SystemMaxUse=1G
        SystemMaxFiles=5
        RuntimeMaxUse=100M
      '';
    };
    
    # DNS resolution
    resolved = {
      enable = true;
      dnssec = "true";
      domains = ["~."];
      fallbackDns = ["1.1.1.1" "8.8.8.8"];
    };
    
    # Automatic system updates (disabled by default for stability)
    # Enable on servers that need automatic security updates
    automatic-updates.enable = false;
    
    # Firmware updates for supported hardware
    fwupd.enable = true;
    
    # Disk optimization
    fstrim.enable = true;
  };

  # Network configuration
  networking = {
    # Enable strict reverse path filtering
    firewall = {
      enable = lib.mkDefault true;
      allowPing = true;
      logReversePathDrops = true;
    };
    
    # Modern network stack
    useNetworkd = lib.mkDefault true;
  };

  # Console and boot configuration
  console = {
    earlySetup = true;
    # Use terminus font for better readability on Pi displays
    font = lib.mkDefault "Lat2-Terminus16";
  };

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "ondemand";
  };

  # Hardware optimization
  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = false; # Only enable redistributable firmware by default
  };

  # Localization
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
    ];
  };

  # Timezone (can be overridden by hosts)
  time.timeZone = lib.mkDefault "UTC";

  # System packages for all NixOS hosts
  environment.systemPackages = with pkgs; [
    # System administration
    htop
    iotop
    lsof
    psmisc
    
    # Network debugging
    tcpdump
    ethtool
    
    # File system tools
    dosfstools
    ntfs3g
    
    # Archive tools
    unzip
    zip
    
    # Text processing
    less
    more
    
    # System information
    inxi
    usbutils
    pciutils
  ];

  # Kernel configuration
  boot = {
    # Enable sysrq key for emergency situations
    kernel.sysctl = {
      "kernel.sysrq" = 1;
      # Network security
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    };
    
    # Kernel modules for common hardware
    kernelModules = [
      "tcp_bbr" # Better congestion control
    ];
    
    # Enable BBR congestion control
    kernel.sysctl."net.core.default_qdisc" = "fq";
    kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
  };

  # User configuration defaults
  users = {
    # Disable mutable users for declarative user management
    mutableUsers = lib.mkDefault false;
    
    # Default shell
    defaultUserShell = pkgs.zsh;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Documentation
  documentation = {
    # Enable man pages
    man.enable = true;
    # Disable info pages to save space (can be enabled per-host if needed)
    info.enable = false;
    # Disable nixos manual for headless systems (can be enabled per-host)
    nixos.enable = lib.mkDefault false;
  };
}
