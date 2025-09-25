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
  networking.hostName = myvars.hosts.nas.hostname;

  # Boot configuration for ZFS root with legacy GRUB
  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
    loader.grub = {
      enable = true;
      zfsSupport = true;
      efiSupport = false;
      device = "/dev/disk/by-id/ata-WDC_WDS500G1R0A-68A4W0_2041DA803271"; # System SSD for bootloader
    };
    # Bare-metal hardware configuration
    initrd.availableKernelModules = [ "ehci_pci" "ata_piix" "uhci_hcd" "xhci_pci_renesas" "usbhid" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-intel" ]; # Change to "kvm-amd" if using AMD host

    # ZFS ARC memory limits for KVM hypervisor with 16GB RAM
    extraModprobeConfig = ''
      options zfs zfs_arc_max=4294967296
      options zfs zfs_arc_min=1073741824
    '';
  };

  # ZFS-specific configuration
  networking.hostId = "8425e349"; # Required for ZFS - matches system hostId

  # Memory management for KVM hypervisor with limited RAM
  zramSwap = {
    enable = true;
    memoryPercent = 25; # Conservative 4GB zram for 16GB RAM system
    algorithm = "zstd"; # Best compression ratio
    priority = 5; # Lower priority to discourage active use
  };

  # Memory management tuning
  boot.kernel.sysctl = {
    "vm.swappiness" = 10; # Prefer RAM over swap for KVM host
    "vm.dirty_background_ratio" = 5; # Reduce dirty memory pressure with ZFS ARC
    "vm.dirty_ratio" = 10; # Lower dirty memory threshold for stability
  };

  # NOTE: nixpkgs.hostPlatform and allowUnfree are set by the outputs system

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

    # Samba file sharing service
    samba = {
      enable = true;
      openFirewall = false; # Firewall already configured above
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "NAS Server";
          "netbios name" = "nas";
          "security" = "user";
          "hosts allow" = "192.168. 10. 127.";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
          # Performance and compatibility
          "server min protocol" = "SMB2";
          "deadtime" = "30";
          "use sendfile" = "yes";
          "max connections" = "10";
        };
        # NAS storage dataset shares
        "media" = {
          "path" = "/mnt/media";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0664";
          "directory mask" = "0775";
          "valid users" = "@nas-users";
          "force group" = "nas-users";
        };
        "backup" = {
          "path" = "/mnt/backup";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0664";
          "directory mask" = "0775";
          "valid users" = "@nas-users";
          "force group" = "nas-users";
        };
        "app_config" = {
          "path" = "/mnt/app_config";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0664";
          "directory mask" = "0775";
          "valid users" = "@nas-users";
          "force group" = "nas-users";
        };
      };
    };

  };

  # Set permissions on NAS storage datasets after mount
  systemd.services.nas-storage-permissions = {
    description = "Set permissions on NAS storage datasets";
    after = [ "zfs-mount.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Set ownership and permissions for storage datasets
      ${pkgs.coreutils}/bin/chown root:nas-users /mnt/app_config /mnt/media /mnt/backup
      ${pkgs.coreutils}/bin/chmod 2775 /mnt/app_config /mnt/media /mnt/backup
    '';
  };

  # Set up Samba users after samba service starts
  systemd.services.samba-user-setup = {
    description = "Set up Samba users";
    after = [ "samba-smbd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Add service user to Samba user database if not already present
      if ! ${pkgs.samba}/bin/pdbedit -L | ${pkgs.gnugrep}/bin/grep -q "^nas-user:"; then
        echo "Setting up Samba service user: nas-user"
        # Note: This creates the user but requires manual password setup
        # Run: sudo smbpasswd -a nas-user
        ${pkgs.samba}/bin/pdbedit -a -u nas-user -t || true
      fi

      # Also add main user to Samba user database if not already present
      if ! ${pkgs.samba}/bin/pdbedit -L | ${pkgs.gnugrep}/bin/grep -q "^${myvars.user.username}:"; then
        echo "Setting up Samba user: ${myvars.user.username}"
        # Note: This creates the user but requires manual password setup
        # Run: sudo smbpasswd -a ${myvars.user.username}
        ${pkgs.samba}/bin/pdbedit -a -u ${myvars.user.username} -t || true
      fi
    '';
  };

  # Network configuration
  networking = {
    networkmanager.enable = true;
    # Disable systemd-networkd to avoid conflict with NetworkManager
    useNetworkd = lib.mkForce false;
    # Firewall configuration for NAS services
    firewall = {
      enable = true;
      # Common NAS ports - can be customized based on services needed
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
        445 # SMB
        2049 # NFS
        8080 # Web UI (alternative)
        9090 # Cockpit web console
      ];
      allowedUDPPorts = [
        137 # NetBIOS Name Service
        138 # NetBIOS Datagram Service
        2049 # NFS
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      # NAS-specific tools
      iotop # I/O monitoring
      ncdu # Disk usage analyzer
      rsync # File synchronization
      rclone # Cloud storage sync
      # Disk performance
      zfs
      fio
      sysstat
      hdparm
      smartmontools
      nvme-cli
      arcstat
      arc_summary
      btop
      util-linux
      gptfdisk
      # System administration
      htop
      tmux
      tree
      wget
      curl
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

  # Group configuration for NAS storage access
  users.groups.nas-users = {
    gid = 1000; # Fixed GID for consistent SMB/NFS sharing
  };

  # Service user for Samba access
  users.users.nas-user = {
    isSystemUser = true;
    description = "NAS Samba service user";
    group = "nas-users";
    extraGroups = [
      "storage" # Access to storage devices
    ];
    createHome = false;
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
      "storage" # Access to storage devices
      "nas-users" # Access to NAS storage datasets
    ];

    # SSH key authentication - configure with your public key
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICNBEKkYPumCLWgGGgvJ6Gr9FPtF8i1U5TBB2IrJnFV9"
    ];

    # Allow setting passwords manually after first boot
    hashedPassword = null;
  };

  # Security configuration
  security = {
    # Require sudo password for security
    sudo.wheelNeedsPassword = lib.mkForce true;
  };

  # Host-specific localization
  time.timeZone = lib.mkForce "America/Los_Angeles";
  i18n.defaultLocale = lib.mkForce "en_US.UTF-8";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Don't change this after initial installation.
  system.stateVersion = "25.05";
}
