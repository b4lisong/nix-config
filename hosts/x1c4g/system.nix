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
      fbterm
    ];

    interactiveShellInit = ''
      # start fbterm with 256 colors
      if [ "$TERM" = "linux" ] && [ -z "$FBTERM" ]; then
          echo -en "\e]P0222222" #black
          echo -en "\e]P8222222" #darkgrey
          echo -en "\e]P1803232" #darkred
          echo -en "\e]P9982b2b" #red
          echo -en "\e]P25b762f" #darkgreen
          echo -en "\e]PA89b83f" #green
          echo -en "\e]P3aa9943" #brown
          echo -en "\e]PBefef60" #yellow
          echo -en "\e]P4324c80" #darkblue
          echo -en "\e]PC2b4f98" #blue
          echo -en "\e]P5706c9a" #darkmagenta
          echo -en "\e]PD826ab1" #magenta
          echo -en "\e]P692b19e" #darkcyan
          echo -en "\e]PEa1cdcd" #cyan
          echo -en "\e]P7ffffff" #lightgrey
          echo -en "\e]PFdedede" #white
          FBTERM=1 exec fbterm
      fi
    '';
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
    wrappers = {
      # Give fbterm permissions so keyboard shortcuts work
      fbterm = {
        owner = "root";
        group = "root";
        capabilities = "cap_sys_tty_config+ep";
        source = "${pkgs.fbterm}/bin/fbterm";
      };
    };
  };

  # Host-specific localization
  time.timeZone = lib.mkForce "America/Los_Angeles";
  i18n.defaultLocale = lib.mkForce "en_US.UTF-8";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Don't change this after initial installation.
  system.stateVersion = "25.05";
}
