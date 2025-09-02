{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  vars,
  ...
}: {
  # Import user configuration layers for Pi development setup
  imports = [
    # Core profile with essential CLI tools
    ../../home/profiles/base

    # TUI profile - perfect for headless Raspberry Pi
    ../../home/profiles/tui

    # Development role for programming projects
    ../../home/roles/dev

    # Docker host role
    ../../home/roles/docker
  ];

  # Home Manager configuration
  home = {
    username = vars.user.username;
    homeDirectory = lib.mkForce "/home/${vars.user.username}";

    # Host-specific packages for this particular Pi
    packages = with pkgs;
      [

      ]
      ++ [
        # Latest (unstable) packages
        # pkgs-unstable.nodejs_latest # Latest Node.js for modern JS projects
      ];
  };

  # Git configuration using centralized variables
  programs.git = {
    userName = vars.git.userName;
    userEmail = vars.git.userEmail;
  };

  # Pi-specific shell configuration
  programs.zsh = {
    # Host-specific aliases and functions
    shellAliases = {
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. Don't change this after
  # the initial installation.
  home.stateVersion = "25.05";
}

