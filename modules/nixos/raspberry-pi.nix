/*
`modules/nixos/raspberry-pi.nix`
Base hardware configuration for Raspberry Pi devices
Provides common Pi hardware support, optimizations, and configurations

This module extracts all the generic Raspberry Pi hardware concerns
from host-specific configurations, making it easy to provision new
Pi devices for different purposes (development, IoT, gateways, etc.)

Features provided:
- SD card image configuration and boot setup
- Pi-specific hardware support (graphics, firmware, kernel modules)
- Performance optimizations for SD card longevity
- Hardware access permissions (GPIO, I2C, SPI)
- Core Pi system packages and tools
- Network configuration suitable for headless operation
- Security hardening appropriate for embedded devices

This module can be imported by any Pi host configuration and
customized through options and overrides as needed.
*/
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  # Import the generic SD card image configuration for ARM
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  # Boot configuration optimized for Raspberry Pi
  boot = {
    # Use U-Boot instead of GRUB for ARM systems
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    # Use mainline kernel for better hardware support (audio, Bluetooth)
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    
    # Raspberry Pi hardware support - kernel modules
    initrd.availableKernelModules = [
      "xhci_pci" 
      "usbhid" 
      "usb_storage"
    ];
    
    # Enable I2C and SPI for hardware projects (via kernel modules)
    kernelModules = ["i2c-dev" "spi-dev"];

    # Performance optimizations for SD card longevity
    kernel.sysctl = {
      # Reduce swappiness for SD card longevity
      "vm.swappiness" = lib.mkDefault 1;
      # Optimize for flash storage
      "vm.dirty_ratio" = lib.mkDefault 5;
      "vm.dirty_background_ratio" = lib.mkDefault 2;
    };
  };

  # Hardware configuration for Raspberry Pi
  hardware = {
    # Enable OpenGL support
    graphics = {
      enable = lib.mkDefault true;
    };
    
    # Enable common hardware support
    enableRedistributableFirmware = lib.mkDefault true;
  };

  # Filesystem configuration for SD card
  fileSystems = {
    "/" = {
      device = lib.mkDefault "/dev/disk/by-label/NIXOS_SD";
      fsType = lib.mkDefault "ext4";
      options = lib.mkDefault ["noatime"];
    };
  };

  # Network configuration suitable for headless operation
  networking = {
    # Enable wireless networking by default
    wireless.enable = lib.mkDefault true;
    # Disable NetworkManager for simpler headless setup
    networkmanager.enable = lib.mkDefault false;
  };

  # SSH configuration for secure remote access
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      # Secure defaults for headless devices
      PasswordAuthentication = lib.mkDefault false;
      KbdInteractiveAuthentication = lib.mkDefault false;
      # Root login disabled by default (can be overridden per host)
      PermitRootLogin = lib.mkDefault "no";
    };
  };

  # User groups for Pi hardware access
  # Host configurations should add users to these groups as needed
  users.groups = {
    gpio = {}; # GPIO access for Pi-specific projects
    i2c = {};  # I2C access for sensors
    spi = {};  # SPI access for peripherals
  };

  # System packages essential for Pi operation
  environment.systemPackages = with pkgs; [
    # Pi-specific tools
    libraspberrypi      # Raspberry Pi userland tools
    raspberrypi-eeprom  # EEPROM updates
    
    # Hardware monitoring essentials
    lm_sensors
    
    # Network tools for headless operation
    wget
    curl
    dig
    
    # Essential system tools
    htop
    vim
    nano
  ];

  # Nix configuration optimized for Pi
  nix = {
    # Automatic garbage collection to save SD card space
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 30d";
    };
  };

  # System services optimized for Pi
  services = {
    # Journal configuration for SD card longevity
    journald.extraConfig = lib.mkDefault ''
      SystemMaxUse=100M
      RuntimeMaxUse=50M
    '';
    
    # Network time synchronization
    timesyncd.enable = lib.mkDefault true;
    
    # Firmware updates for supported hardware
    fwupd.enable = lib.mkDefault true;
  };

  # Security configuration appropriate for embedded devices
  security = {
    # Sudo configuration - can be overridden per host
    sudo.wheelNeedsPassword = lib.mkDefault true;
  };

  # Console configuration optimized for Pi displays
  console = {
    font = lib.mkDefault "Lat2-Terminus16";
    useXkbConfig = lib.mkDefault true;
  };

  # Power management for embedded device
  powerManagement = {
    enable = lib.mkDefault true;
    cpuFreqGovernor = lib.mkDefault "ondemand";
  };

  # Localization defaults (can be overridden per host)
  time.timeZone = lib.mkDefault "UTC";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  # Documentation settings for resource-constrained devices
  documentation = {
    # Disable heavy documentation by default to save space
    nixos.enable = lib.mkDefault false;
    man.enable = lib.mkDefault true;
    info.enable = lib.mkDefault false;
  };
}