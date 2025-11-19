{
  config,
  lib,
  pkgs,
  myvars,
  ...
}: {
  # Host identification
  networking.hostName = myvars.hosts.oci-nixos.hostname;

  # Boot configuration
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # Filesystem configuration matching disko layout
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
    "/srv" = {
      device = "/dev/disk/by-label/srv";
      fsType = "ext4";
    };
  };

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
    # Firewall configuration (managed at cloud level)
    # Uncomment and configure if host-level firewall is needed:
    # firewall = {
    #   enable = true;
    #   allowedTCPPorts = [ 22 80 443 ];
    #   allowedUDPPorts = [ ];
    # };
  };

  # Essential packages for cloud server
  environment.systemPackages = with pkgs; [
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

  # User configuration specific to this host
  users.users.${myvars.user.username} = {
    isNormalUser = true;
    description = myvars.user.fullName;
    extraGroups = [
      "wheel" # sudo access
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Don't change this after initial installation.
  system.stateVersion = "25.05";
}
