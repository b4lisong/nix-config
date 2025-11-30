{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  myvars,
  ...
}: {
  # Import user configuration layers
  imports = [
    # Core profile with essential CLI tools
    ../../home/profiles/base

    # TUI profile for terminal interface
    ../../home/profiles/tui
  ];

  # Home Manager configuration
  home = {
    username = myvars.user.username;
    homeDirectory = lib.mkForce "/home/${myvars.user.username}";

    # Host-specific packages for NAS functionality
    packages = with pkgs; [
      # File management and monitoring
      dust # Better du alternative
      fd # Better find alternative
      ripgrep # Better grep alternative

      # Network tools
      iperf3 # Network performance testing
      nmap # Network discovery

      # Archive tools
      unzip
      zip
      p7zip
    ];
  };

  programs.gpg.enable = true;
  services.gpg-agent.enable = true;

  # Host-specific shell configuration
  programs.zsh = {
    # NAS-specific aliases
    shellAliases = {
      # Disk usage shortcuts
      duf = "du -sh * | sort -hr";
      # Network shortcuts
      myip = "curl -s https://ipinfo.io/ip";
    };

    # Auto-start tmux for SSH connections (safe version)
    initContent = ''
      # Auto-start tmux only for SSH connections
      if command -v tmux &> /dev/null && [ -n "$PS1" ] && \
         [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ] && \
         ([ -n "$SSH_CONNECTION" ] || [ -n "$SSH_TTY" ]); then
        # Check if any tmux sessions exist
        if tmux list-sessions &>/dev/null; then
          # Attach to the first available session (without exec)
          tmux attach-session
        else
          # Create a new session (without exec)
          tmux new-session
        fi
      fi
    '';
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. Don't change this after
  # the initial installation.
  home.stateVersion = "25.05";
}