{
  config,
  lib,
  pkgs,
  vars,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/docker.nix
  ];

  # Host identification
  networking.hostName = vars.hosts.x1c4g.hostname;

  # Boot configuration
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  # Platform architecture configuration
  nixpkgs = {
    hostPlatform = vars.hosts.x1c4g.system;
    config = {
      allowUnfree = true;
    };
  };

  # Docker configuration
  virtualisation.docker.enable = true;

  # Host-specific service configuration
  services = {
    # SSH configuration for initial setup
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = lib.mkForce "no";
      };
    };

    # Console replacement with better terminal support
    kmscon = {
      enable = true;
      # Use hardware acceleration for better performance
      hwRender = true;
      # Use xserver keyboard settings for consistent keymap
      useXkbConfig = true;
      # Set 256-color terminal support
      extraOptions = "--term xterm-256color";
      extraConfig = ''
        font-size=20
        
        # Catppuccin Mocha color scheme
        palette=custom
        color0=1e1e2e
        color1=f38ba8
        color2=a6e3a1
        color3=f9e2af
        color4=89b4fa
        color5=f5c2e7
        color6=94e2d5
        color7=bac2de
        color8=585b70
        color9=f38ba8
        color10=a6e3a1
        color11=f9e2af
        color12=89b4fa
        color13=f5c2e7
        color14=94e2d5
        color15=a6adc8
        
        # Background and foreground
        back-color=1e1e2e
        fore-color=cdd6f4
      '';
    };

    /*
    # Tailscale VPN configuration
    tailscale = {
      enable = true;
      useRoutingFeatures = "server"; # enables IP forwarding
    };
    */
  };

  # Network configuration
  networking = {
    networkmanager.enable = true;
    # Disable systemd-networkd to avoid conflict with NetworkManager
    useNetworkd = lib.mkForce false;
    # Firewall configuration
    firewall = {
      /*
      # Trust Tailscale interface for VPN traffic
      trustedInterfaces = ["tailscale0"];

      # UDP ports
      allowedUDPPorts = [config.services.tailscale.port];

      # TCP ports for web services
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
        8080 # Alternative HTTP (development/apps)
        3000 # Altnernative HTTP #2
      ];
      */
      enable = false;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      #tailscale
    ];
  };

  # User configuration specific to this host
  users.users.${vars.user.username} = {
    isNormalUser = true;
    description = vars.user.fullName;
    extraGroups = [
      "wheel" # sudo access
      "networkmanager"
      "audio"
      "video"
      "docker" # Docker access
    ];

    # SSH key authentication - configured for this specific host
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICNBEKkYPumCLWgGGgvJ6Gr9FPtF8i1U5TBB2IrJnFV9"
    ];

    # Allow setting passwords manually after first boot
    hashedPassword = null;
  };

  # Security configuration for initial setup
  security = {
    # Disable sudo password for initial setup convenience
    # Consider restricting this after initial configuration
    sudo.wheelNeedsPassword = lib.mkForce false;
  };

  # Host-specific localization
  time.timeZone = lib.mkForce "America/Los_Angeles";
  i18n.defaultLocale = lib.mkForce "en_US.UTF-8";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Don't change this after initial installation.
  system.stateVersion = "25.05";
}
