{
  config,
  lib,
  pkgs,
  myvars,
  ...
}: {
  # NOTE: imports are now handled by the outputs system
  # raspberry-pi.nix and docker.nix are imported automatically

  # Host identification
  networking.hostName = myvars.hosts.rpi4b.hostname;

  # NOTE: nixpkgs.hostPlatform and allowUnfree are set by the outputs system

  # Docker configuration
  virtualisation.docker.enable = true;

  # Host-specific service configuration
  services = {
    # SSH configuration for initial setup
    openssh.settings = {
      # Allow root login for initial setup (override base Pi module default)
      # Disable after first login and proper user setup
      PermitRootLogin = lib.mkForce "yes";
    };

    # Tailscale VPN configuration
    tailscale = {
      enable = true;
      useRoutingFeatures = "server"; # enables IP forwarding
    };
  };

  # Network configuration
  networking = {
    # Disable wireless networking for wired-only Pi (override Pi base module default)
    wireless.enable = lib.mkForce false;

    # Firewall configuration
    firewall = {
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
    };
  };

  # Make tailscale CLI available to users
  environment.systemPackages = with pkgs; [
    tailscale
  ];

  # User configuration specific to this Pi
  users.users.${myvars.user.username} = {
    isNormalUser = true;
    description = myvars.user.fullName;
    extraGroups = [
      "wheel" # sudo access
      "networkmanager"
      "audio"
      "video"
      "gpio" # GPIO access for Pi-specific projects
      "i2c" # I2C access for sensors
      "spi" # SPI access for peripherals
      "docker" # Docker access
    ];

    # SSH key authentication - configured for this specific Pi
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICNBEKkYPumCLWgGGgvJ6Gr9FPtF8i1U5TBB2IrJnFV9"
    ];

    # Allow setting passwords manually after first boot
    hashedPassword = null;
  };

  # Security configuration for initial setup
  # Disable sudo password for initial setup convenience
  # Consider restricting this after initial configuration
  security.sudo.wheelNeedsPassword = lib.mkForce false;

  # Host-specific localization
  time.timeZone = lib.mkForce "America/Los_Angeles";
  i18n.defaultLocale = lib.mkForce "en_US.UTF-8";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Don't change this after initial installation.
  system.stateVersion = "25.05";
}
