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
        font-name=SauceCodePro Nerd Font Mono
        font-size=20
        
        # Catppuccin Mocha color scheme
        palette=custom
        palette-foreground=205, 214, 244
        palette-background=30, 30, 46
        palette-black=30, 30, 46
        palette-red=243, 139, 168
        palette-green=166, 227, 161
        palette-yellow=249, 226, 175
        palette-blue=137, 180, 250
        palette-magenta=245, 194, 231
        palette-cyan=148, 226, 213
        palette-light-grey=186, 194, 222
        palette-dark-grey=88, 91, 112
        palette-light-red=243, 139, 168
        palette-light-green=166, 227, 161
        palette-light-yellow=249, 226, 175
        palette-light-blue=137, 180, 250
        palette-light-magenta=245, 194, 231
        palette-light-cyan=148, 226, 213
        palette-white=166, 173, 200
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
