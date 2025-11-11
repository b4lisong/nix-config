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
  networking.hostName = myvars.hosts.nixvm.hostname;

  # Boot configuration
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

    # Load vhci-hcd kernel module on startup (for USB/IP)
    # Using mkAfter to append to hardware-configuration.nix list
    kernelModules = lib.mkAfter ["vhci-hcd"];
  };

  # NOTE: nixpkgs.hostPlatform and allowUnfree are set by the outputs system

  # Host-specific service configuration
  services = {
    # SSH configuration for initial setup
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = lib.mkForce "no";
      };
    };

    # Enable GNOME keyring for secure credential storage
    gnome.gnome-keyring.enable = true;

    # libinput for natural scrolling
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };

    # X11 display server configuration for graphical desktop
    xserver = {
      enable = true;
      # Comment out below if already swapped on the host (e.g. macOS)
      # xkb.options = "caps:swapescape"; # Swap Caps Lock and Escape keys for vim ergonomics
      dpi = 192; # Increase DPI for HiDPI display
      # Desktop manager configuration
      desktopManager = {
        xterm.enable = false; # Disable default xterm terminal
        # XFCE configuration as session manager without desktop/window management
        xfce = {
          enable = true;
          noDesktop = true; # Don't use XFCE desktop, only session management
          enableXfwm = false; # Disable XFCE window manager, using i3 instead
        };
      };
      # i3 tiling window manager configuration
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu # Application launcher for i3
        ];
      };
    };

    # Set XFCE as the default display manager session
    # This provides session management while i3 handles window management
    displayManager.defaultSession = "xfce+i3";

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
      linuxPackages.usbip # USB/IP userspace utility
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
    # Enable GNOME keyring integration with PAM for automatic unlock on login
    pam.services.gdm.enableGnomeKeyring = true;
  };

  # Host-specific localization
  time.timeZone = lib.mkForce "America/Los_Angeles";
  i18n.defaultLocale = lib.mkForce "en_US.UTF-8";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Don't change this after initial installation.
  system.stateVersion = "25.05";
}
