{
  config,
  lib,
  pkgs,
  myvars,
  ...
}: {
  # NOTE: imports are now handled by the outputs system
  # raspberry-pi.nix is imported automatically

  # Host identification
  networking.hostName = myvars.hosts.rpiz2w.hostname;

  # NOTE: nixpkgs.hostPlatform and allowUnfree are set by the outputs system

  # Host-specific service configuration
  services = {
    # SSH configuration for remote access
    openssh.settings = {
      # Allow root login for initial setup (override base Pi module default)
      # Disable after first login and proper user setup
      PermitRootLogin = lib.mkForce "yes";
    };
  };

  # Network configuration
  networking = {
    # Enable wireless networking for Pi Zero 2 W
    wireless.enable = true;

    # Disable firewall for bare-bones setup
    firewall.enable = false;
  };

  # User configuration specific to this Pi
  users.users.${myvars.user.username} = {
    isNormalUser = true;
    description = myvars.user.fullName;
    extraGroups = [
      "wheel" # sudo access
      "networkmanager"
      "audio"
      "video"
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
