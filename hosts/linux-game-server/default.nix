{
  config,
  lib,
  pkgs,
  myvars,
  ...
}:
# Game Server VM NixOS Configuration
#
# This configuration is for a game server running as a Hyper-V VM.
# It includes steamcmd for installing and managing game servers.
#
# Disk layout is defined in disks.nix for use with disko during installation.
{
  # Filesystem configuration matching disko layout (see disks.nix)
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };

  # Host identification
  networking.hostName = myvars.hosts."game-server".hostname;

  # Boot configuration for Hyper-V VM
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
    # Hyper-V guest support
    initrd.availableKernelModules = [
      "sd_mod"
      "sr_mod"
      "hv_vmbus"
      "hv_storvsc"
      "hv_netvsc"
    ];
  };

  # Hyper-V guest services
  virtualisation.hypervGuest.enable = true;

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
    firewall.enable = false;
  };

  # Game server packages
  environment.systemPackages = with pkgs; [
    steamcmd
    # Basic system tools
    curl
    wget
    htop
    git
  ];

  programs = {
    # GnuPG agent for SSH key management
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # User configuration
  users.users.${myvars.user.username} = {
    isNormalUser = true;
    description = myvars.user.fullName;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    # SSH key authentication
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICNBEKkYPumCLWgGGgvJ6Gr9FPtF8i1U5TBB2IrJnFV9"
    ];

    hashedPassword = null;
  };

  # Security configuration
  security.sudo.wheelNeedsPassword = lib.mkForce false;

  # Host-specific localization
  time.timeZone = lib.mkForce "America/Los_Angeles";
  i18n.defaultLocale = lib.mkForce "en_US.UTF-8";

  # System state version
  system.stateVersion = "25.11";
}
