{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  vars,
  ...
}: {
  # Import user configuration layers
  imports = [
    # Core profile with essential CLI tools
    ../../home/profiles/base

    # TUI profile
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

    # Host-specific packages
    packages = with pkgs;
      [

      ]
      ++ [
        # Latest (unstable) packages
        # pkgs-unstable.nodejs_latest # Latest Node.js for modern JS projects
      ];
  };

  # SSH configuration for Git authentication
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
        HostName github.com
        User git
        IdentityFile ~/.ssh/id_ed25519
        IdentitiesOnly yes
    '';
  };

  # Git configuration using centralized variables
  programs.git = {
    userName = vars.git.userName;
    userEmail = vars.git.userEmail;
    extraConfig = {
      # Force SSH for GitHub URLs
      url."git@github.com:".insteadOf = "https://github.com/";
      # SSH signing configuration (optional)
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
    };
  };

  # Host-specific shell configuration
  programs.zsh = {
    # Host-specific aliases and functions
    shellAliases = {
    };
    
    # TERM configuration for proper terminal handling
    initContent = ''
      case "$TERM" in
          xterm*)
              if [ -e "${pkgs.ncurses}/share/terminfo/x/xterm-256color" ]; then
                  export TERM=xterm-256color
              elif [ -e "${pkgs.ncurses}/share/terminfo/x/xterm-color" ]; then
                  export TERM=xterm-color;
              else
                  export TERM=xterm
              fi
              ;;
          linux)
              [ -n "$FBTERM" ] && export TERM=fbterm
              ;;
      esac
    '';
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. Don't change this after
  # the initial installation.
  home.stateVersion = "25.05";
}

