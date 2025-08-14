/*
`modules/nixos/docker.nix`
Generic Docker system configuration for NixOS hosts

This module provides Docker daemon configuration that works across all NixOS
systems regardless of architecture (x86_64, aarch64, etc.). It focuses on
providing a secure, well-configured Docker environment with sensible defaults.

Platform-specific optimizations should be handled in platform-specific modules
(e.g., raspberry-pi.nix for ARM/Pi optimizations).

Features provided:
- Docker daemon with secure defaults
- Rootless Docker support option
- User group management
- Basic storage and network configuration
- System service management

This module is designed to be imported by any NixOS host that needs Docker
support, with all settings using lib.mkDefault for easy customization.
*/
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Docker virtualization configuration
  virtualisation.docker = {
    # Enable Docker daemon
    enable = lib.mkDefault false; # Must be explicitly enabled by hosts
    
    # Enable rootless Docker for improved security
    # Rootless mode runs Docker daemon as unprivileged user
    rootless = {
      enable = lib.mkDefault true;
      setSocketVariable = lib.mkDefault true;
    };
    
    # Docker daemon configuration
    daemon.settings = {
      # Logging configuration
      log-driver = lib.mkDefault "journald";
      log-opts = lib.mkDefault {
        max-size = "100m";
        max-file = "3";
      };
      
      # Storage driver (let Docker auto-detect best option)
      # Common options: overlay2 (most systems), devicemapper (older systems)
      storage-driver = lib.mkDefault null; # Auto-detect
      
      # Network configuration
      bridge = lib.mkDefault "docker0";
      iptables = lib.mkDefault true;
      
      # Security configuration
      no-new-privileges = lib.mkDefault true;
      
      # Resource management defaults
      default-ulimits = lib.mkDefault {
        nofile = {
          name = "nofile";
          hard = 64000;
          soft = 64000;
        };
      };
    };
    
    # Enable Docker at boot
    enableOnBoot = lib.mkDefault true;
    
    # Automatic container cleanup
    autoPrune = {
      enable = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      flags = lib.mkDefault [
        "--filter=until=168h" # Remove containers older than 1 week
        "--filter=label!=keep" # Don't prune containers labeled with 'keep'
      ];
    };
  };

  # User configuration for Docker access
  users.groups.docker = lib.mkIf config.virtualisation.docker.enable {};
  
  # System packages for Docker management
  environment.systemPackages = lib.mkIf config.virtualisation.docker.enable (with pkgs; [
    # Docker CLI tools are typically provided by the docker role
    # Only include system-level management tools here
    docker-buildx # Extended build capabilities
  ]);

  # Firewall configuration for Docker
  networking.firewall = lib.mkIf config.virtualisation.docker.enable {
    # Allow Docker daemon to manage iptables
    # Docker needs to create rules for container networking
    trustedInterfaces = lib.mkDefault [ "docker0" ];
  };

  # Systemd service optimizations
  systemd.services.docker = lib.mkIf config.virtualisation.docker.enable {
    # Resource limits for Docker daemon
    serviceConfig = {
      # Limit Docker daemon memory usage
      MemoryMax = lib.mkDefault "1G";
      # Restart policy
      Restart = lib.mkDefault "always";
      RestartSec = lib.mkDefault "10s";
    };
  };

  # Kernel modules required for Docker
  boot.kernelModules = lib.mkIf config.virtualisation.docker.enable [
    "bridge"     # Bridge networking
    "veth"       # Virtual ethernet
    "xt_nat"     # NAT support
    "ip_tables"  # iptables support
    "iptable_nat"
    "iptable_filter"
  ];

  # Kernel parameters for better container support
  boot.kernel.sysctl = lib.mkIf config.virtualisation.docker.enable {
    # Network configuration for containers
    "net.bridge.bridge-nf-call-iptables" = lib.mkDefault 1;
    "net.bridge.bridge-nf-call-ip6tables" = lib.mkDefault 1;
    "net.ipv4.ip_forward" = lib.mkDefault 1;
    
    # Virtual memory settings for containers
    "vm.max_map_count" = lib.mkDefault 262144; # Required for some containers (e.g., Elasticsearch)
  };

  # Security configuration
  security = lib.mkIf config.virtualisation.docker.enable {
    # Allow users in docker group to run Docker commands
    # This is automatically handled by the Docker service
    # No additional sudo rules needed for rootless Docker
  };
}