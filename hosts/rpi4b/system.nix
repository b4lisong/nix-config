{
  config,
  lib,
  pkgs,
  modulesPath,
  vars,
  ...
}: {
  # Import the generic SD card image configuration for ARM
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  # Host identification
  networking.hostName = vars.hosts.rpi4b.hostname;

  # Platform architecture configuration
  nixpkgs = {
    hostPlatform = vars.hosts.rpi4b.system;
    config = {
      allowUnfree = true;
    };
  };

  # Boot configuration for Raspberry Pi 4B
  boot = {
    # Use U-Boot instead of GRUB for ARM systems
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    # Enable hardware-specific features
    # Use mainline kernel for better hardware support (audio, Bluetooth)
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Raspberry Pi 4 hardware support
    initrd.availableKernelModules = [
      "xhci_pci" 
      "usbhid" 
      "usb_storage"
    ];
  };

  # Hardware-specific configuration for Raspberry Pi 4B
  hardware = {
    # Enable OpenGL support
    graphics = {
      enable = true;
    };
    
    # Enable common hardware support
    enableRedistributableFirmware = true;
  };

  # Firmware configuration
  # Note: For advanced firmware config, consider using raspberry-pi-nix flake
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };
  };

  # Network configuration
  networking = {
    wireless.enable = true; # Enable wireless networking
    networkmanager.enable = lib.mkForce false; # Disable NetworkManager for headless setup
  };

  # SSH configuration for remote access
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      # Allow root login for initial setup
      # Disable after first login and proper user setup
      PermitRootLogin = "yes";
    };
  };

  # User configuration
  users.users.${vars.user.username} = {
    isNormalUser = true;
    description = vars.user.fullName;
    extraGroups = [
      "wheel"      # sudo access
      "networkmanager" 
      "audio"
      "video"
      "gpio"       # GPIO access for Pi-specific projects
      "i2c"        # I2C access for sensors
      "spi"        # SPI access for peripherals
    ];
    
    # SSH key authentication - ADD YOUR SSH PUBLIC KEY HERE
    openssh.authorizedKeys.keys = [
      # Add your SSH public key here for secure access
      # Example: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5... user@host"
    ];
    
    # Temporary: allow setting passwords manually after first boot
    hashedPassword = null;
  };

  # Enable sudo without password for initial setup
  # Consider restricting this after initial configuration
  security.sudo.wheelNeedsPassword = false;

  # System packages specific to Pi usage
  environment.systemPackages = with pkgs; [
    # Pi-specific tools
    libraspberrypi # Raspberry Pi userland tools
    raspberrypi-eeprom # EEPROM updates
    
    # Hardware monitoring
    lm_sensors
    htop
    
    # Network tools for headless operation
    wget
    curl
    dig
    
    # Text editors for emergency config
    vim
    nano
  ];

  # Performance optimizations for SD card
  boot.kernel.sysctl = {
    # Reduce swappiness for SD card longevity
    "vm.swappiness" = 1;
    # Optimize for flash storage
    "vm.dirty_ratio" = 5;
    "vm.dirty_background_ratio" = 2;
  };

  # Enable I2C and SPI for hardware projects (via kernel modules)
  boot.kernelModules = ["i2c-dev" "spi-dev"];

  # Nix configuration for Pi optimizations
  nix = {
    # Automatic garbage collection to save SD card space
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # System services
  services = {
    
    # Journal configuration for SD card longevity
    journald.extraConfig = ''
      SystemMaxUse=100M
      RuntimeMaxUse=50M
    '';
    
    # Network time synchronization
    timesyncd.enable = true;
  };

  # Localization
  time.timeZone = "America/Los_Angeles"; # Adjust as needed
  i18n.defaultLocale = "en_US.UTF-8";

  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Don't change this after initial installation.
  system.stateVersion = "25.05";
}