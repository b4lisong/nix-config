{
  config,
  lib,
  pkgs,
  vars,
  ...
}: {
  # Import base Raspberry Pi hardware configuration and Docker support
  imports = [
    ../../modules/nixos/raspberry-pi.nix
    ../../modules/nixos/docker.nix
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

  # Firewall configuration for Tailscale
  networking.firewall = {
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
  };

  # Make tailscale CLI available to users
  environment.systemPackages = with pkgs; [
    tailscale
  ];

  # User configuration specific to this Pi
  users.users.${vars.user.username} = {
    isNormalUser = true;
    description = vars.user.fullName;
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

