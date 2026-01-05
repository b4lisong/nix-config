{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  myvars,
  ...
}: {
  # Import user configuration layers for cloud server setup
  imports = [
    # Core profile with essential CLI tools
    ../../home/profiles/base

    # TUI profile for headless cloud server
    ../../home/profiles/tui

    # Docker role for container management
    ../../home/roles/docker
  ];

  # Home Manager configuration
  home = {
    username = myvars.user.username;
    homeDirectory = lib.mkForce "/home/${myvars.user.username}";

    # Host-specific packages for cloud server
    packages = with pkgs; [
      # System monitoring and diagnostics
      smartmontools

      # Additional cloud server utilities
    ];
  };

  # Cloud server specific shell configuration
  programs.zsh = {
    shellAliases = {
      # Network utilities
      myip = "curl -s ifconfig.me";
      localip = "ip route get 1 | head -1 | cut -d' ' -f7";
    };
  };

  # Starship prompt customization for cloud server
  programs.starship = {
    settings = {
      # Show memory usage for cloud server monitoring
      memory_usage = {
        disabled = false;
        threshold = 70;
        format = "[$symbol$ram]($style) ";
        symbol = "RAM ";
      };

      # Always show hostname for cloud server identification
      hostname.disabled = false;
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. Don't change this after
  # the initial installation.
  home.stateVersion = "25.05";
}
