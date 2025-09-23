{
  config,
  lib,
  pkgs,
  myvars,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];
  # NOTE: other imports are now handled by the outputs system

  # Host identification
  networking.hostName = myvars.hosts.nas.hostname;

  # Boot configuration for VM
  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/sda"; # Typical for Proxmox VMs
    };
  };

  # Virtualization-specific configuration
  boot = {
    initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "ahci" "sd_mod" ];
    kernelModules = [ "kvm-intel" ]; # Change to "kvm-amd" if using AMD host
  };

  # Enable virtualization services
  services.qemuGuest.enable = true;

  # NOTE: nixpkgs.hostPlatform and allowUnfree are set by the outputs system

  # Host-specific service configuration
  services = {
    # SSH configuration for remote management
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = lib.mkForce "no";
        PasswordAuthentication = false;
      };
    };

  };

  # Network configuration
  networking = {
    networkmanager.enable = true;
    # Disable systemd-networkd to avoid conflict with NetworkManager
    useNetworkd = lib.mkForce false;
    # Firewall configuration for NAS services
    firewall = {
      enable = true;
      # Common NAS ports - can be customized based on services needed
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
        445 # SMB
        2049 # NFS
        8080 # Web UI (alternative)
        9090 # Cockpit web console
      ];
      allowedUDPPorts = [
        137 # NetBIOS Name Service
        138 # NetBIOS Datagram Service
        2049 # NFS
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      # NAS-specific tools
      iotop # I/O monitoring
      ncdu # Disk usage analyzer
      rsync # File synchronization
      rclone # Cloud storage sync
      # System administration
      htop
      tmux
      tree
      wget
      curl
    ];
  };

  programs = {
    dconf.enable = true; # Enable dconf for GNOME/GTK application settings
    # GnuPG agent for encryption and SSH key management
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true; # Use GPG agent for SSH authentication
    };
  };

  # User configuration specific to this host
  users.users.${myvars.user.username} = {
    isNormalUser = true;
    description = myvars.user.fullName;
    extraGroups = [
      "wheel" # sudo access
      "networkmanager"
      "audio"
      "video"
      "storage" # Access to storage devices
    ];

    # SSH key authentication - configure with your public key
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICNBEKkYPumCLWgGGgvJ6Gr9FPtF8i1U5TBB2IrJnFV9"
    ];

    # Allow setting passwords manually after first boot
    hashedPassword = null;
  };

  # Security configuration
  security = {
    # Require sudo password for security
    sudo.wheelNeedsPassword = lib.mkForce true;
  };

  # Host-specific localization
  time.timeZone = lib.mkForce "America/Los_Angeles";
  i18n.defaultLocale = lib.mkForce "en_US.UTF-8";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Don't change this after initial installation.
  system.stateVersion = "25.05";
}