{
  config,
  lib,
  pkgs,
  myvars,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    # Enable Docker support
    ../../modules/nixos/docker.nix
  ];

  # Host identification
  networking.hostName = myvars.hosts.oci-nixos.hostname;

  # Boot configuration
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
    initrd.systemd.enable = true;
  };

  # Enable multi-user target for proper boot
  systemd.targets.multi-user.enable = true;

  # Filesystem configuration matching actual disk layout
  fileSystems = {
    "/" = {
      device = "/dev/sda2";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/sda1";
      fsType = "vfat";
    };
    "/srv" = {
      device = "/dev/sdb1";
      fsType = "ext4";
    };
  };

  # Set global read/write permissions on /srv
  systemd.tmpfiles.rules = [
    "d /srv 0777 root root -"
  ];

  # Docker configuration
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
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

    # Tailscale VPN configuration
    tailscale = {
      enable = true;
      useRoutingFeatures = "server"; # enables IP forwarding
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
    # Docker tools
    docker-compose
    # Tailscale CLI
    tailscale
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
      "docker" # Docker access
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
