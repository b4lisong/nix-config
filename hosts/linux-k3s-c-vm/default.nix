{
  config,
  lib,
  pkgs,
  myvars,
  modulesPath,
  ...
}:
# k3s-c-vm NixOS Configuration
#
# This configuration includes automatic mounting of the NAS /mnt/app_config share.
#
# MANUAL SETUP REQUIRED:
# After deploying this configuration, create the CIFS credentials file:
#
# 1. Create credentials file:
#    sudo nano /etc/cifs-credentials
#
# 2. Add credentials (replace <password> with actual NAS password):
#    username=nas-user
#    password=<password>
#
# 3. Secure the file:
#    sudo chown root:root /etc/cifs-credentials
#    sudo chmod 600 /etc/cifs-credentials
#
# 4. Test the mount:
#    sudo systemctl restart mnt-nas-app_config.mount
#    ls -la /mnt/nas/app_config
#
{
  imports = [
    # Include the default incus configuration
    "${modulesPath}/virtualisation/incus-virtual-machine.nix"
  ];

  # Host identification
  networking.hostName = myvars.hosts."k3s-c-vm".hostname;

  # Boot configuration for VM
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
    # Support for CIFS/SMB network filesystems
    supportedFilesystems = [ "cifs" ];
  };

  # k3s configuration
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--disable=servicelb" # add MetalLB later if needed
      "--write-kubeconfig-mode=644"
    ];
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

  # Network configuration for Incus VM (from transferred configuration.nix)
  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
    # Disable firewall for VM environment
    firewall.enable = false;
  };

  # systemd-networkd configuration for Incus VM
  systemd.network = {
    enable = true;
    networks."50-enp5s0" = {
      matchConfig.Name = "enp5s0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  # NAS share mounting configuration
  fileSystems."/mnt/nas/app_config" = {
    device = "//nas/app_config";
    fsType = "cifs";
    options = [
      "credentials=/etc/cifs-credentials"
      "uid=1000"
      "gid=1000"
      "file_mode=0664"
      "dir_mode=0775"
      "nofail"
      "x-systemd.automount"
      "x-systemd.device-timeout=10"
      "x-systemd.mount-timeout=10"
    ];
  };

  # Minimal environment packages for k3s TUI host
  environment = {
    systemPackages = with pkgs; [
      # Essential k3s tools
      kubectl
      helm
      k9s
      # Basic system tools
      curl
      wget
      htop
      git
      # NAS mounting support
      cifs-utils
    ];
  };

  programs = {
    # GnuPG agent for SSH key management
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Group configuration for NAS storage access
  users.groups.nas-users = {
    gid = 1000; # Fixed GID for consistent SMB/NFS sharing
  };

  # User configuration specific to this host
  users.users.${myvars.user.username} = {
    isNormalUser = true;
    description = myvars.user.fullName;
    extraGroups = [
      "wheel" # sudo access
      "networkmanager"
      "nas-users" # Access to NAS storage
    ];

    # SSH key authentication
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICNBEKkYPumCLWgGGgvJ6Gr9FPtF8i1U5TBB2IrJnFV9"
    ];

    hashedPassword = null;
  };

  # Set up NAS mount directory and credentials
  systemd.services.nas-mount-setup = {
    description = "Create NAS mount directory and check credentials";
    before = [ "mnt-nas-app_config.mount" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Create mount directory
      ${pkgs.coreutils}/bin/mkdir -p /mnt/nas/app_config
      # Set proper ownership and permissions
      ${pkgs.coreutils}/bin/chown root:nas-users /mnt/nas/app_config
      ${pkgs.coreutils}/bin/chmod 2775 /mnt/nas/app_config

      # Check for credentials file and set proper permissions if it exists
      if [ -f /etc/cifs-credentials ]; then
        ${pkgs.coreutils}/bin/chown root:root /etc/cifs-credentials
        ${pkgs.coreutils}/bin/chmod 600 /etc/cifs-credentials
        echo "CIFS credentials file found and secured"
      else
        echo "WARNING: /etc/cifs-credentials not found - NAS mount will fail"
        echo "Create the file manually with: username=nas-user"
        echo "                              password=<your_nas_password>"
        echo "Then run: chmod 600 /etc/cifs-credentials"
      fi
    '';
  };

  # Security configuration
  security = {
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
