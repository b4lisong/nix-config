{
  config,
  lib,
  pkgs,
  myvars,
  modulesPath,
  ...
}: {
  imports = [
    # Include the default incus configuration
    "${modulesPath}/virtualisation/incus-virtual-machine.nix"
  ];

  # Host identification
  networking.hostName = myvars.hosts."k3s-c-vm".hostname;

  # Boot configuration for VM
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    efi.canTouchEfiVariables = true;
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
    ];
  };

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
      "networkmanager"
    ];

    # SSH key authentication
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICNBEKkYPumCLWgGGgvJ6Gr9FPtF8i1U5TBB2IrJnFV9"
    ];

    hashedPassword = null;
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
