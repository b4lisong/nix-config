/*
`hosts/darwin-sksm3/default.nix`
Host-specific configuration for the sksm3 host

This file contains ONLY host-specific configuration for sksm3.
Base system configuration (modules/base.nix, modules/darwin) is handled
by the outputs system. Variables are passed as myvars parameter.

Host Information:
- Hostname: sksm3
- Architecture: aarch64-darwin (Apple Silicon MacBook)
- Description: Work MacBook
- Purpose: Professional development and work machine

Configuration Areas:
- Host-specific system preferences
- Homebrew packages for this specific machine
- macOS defaults and environment variables
*/
{
  myvars,
  pkgs,
  ...
}: {
  # No imports needed - handled by outputs system
  # No nixpkgs.hostPlatform needed - handled by outputs system
  # No system.primaryUser needed - handled by outputs system

  # Host-specific system settings
  system = {
    # Manage keyboard settings
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true; # More useful Caps Lock functionality (vim, etc.)
    };
  };

  # User account configuration
  users.users.${myvars.user.username} = {
    name = myvars.user.username;
    home = "/Users/${myvars.user.username}";
    shell = pkgs.${myvars.user.shell};
  };

  # Host-specific Homebrew configuration
  # This extends the defaults from `modules/darwin/homebrew.nix`
  # with applications specific to this work development machine
  homebrew = {
    # Work-appropriate applications and tools
    casks = [
      # Development and productivity tools
      "visual-studio-code" # VS Code
      "claude" # Claude Desktop MCP

      # Professional productivity
      "slack" # Team communication
      "zoom" # Video conferencing
      "sunsama" # Task management & planning

      # Remote access and virtualization
      "parsec" # Low-latency remote desktop for gaming/work
      "vmware-fusion" # Virtualization for testing different OS environments
      "orbstack" # Docker replacement and CLI VMs

      # Browsers
      "google-chrome" # Chrome browser (not available in nixpkgs)

      # Messaging & communications
      "discord" # Voice and text chat

      # VPN
      "tailscale-app"

      # Notes & PKM
      "logseq" # Outliner-style PKM
      "obsidian" # Markdown PKM

      # Utilities
      "balenaetcher"
    ];

    # Command-line tools via Homebrew
    brews = [
      # VPN
      "openvpn" # Corporate VPN access (for clients)
    ];

    # Mac App Store applications
    masApps = {
      "NextDNS" = 1464122853; # DNS service
      "1Password for Safari" = 1569813296;
      # "Tailscale" = 1475387142; # encountered login issues; using homebrew version
    };
  };

  # macOS system defaults and preferences specific to this host
  system.defaults = {
    # Very professional login window text
    loginwindow.LoginwindowText = "such sidekick much security wow";

    # Dock configuration
    dock = {
      # Persistent applications in dock for work productivity
      # persistent-apps = [
      #   "/Applications/Safari.app"
      #   "/Applications/Cursor.app"
      #   "/Applications/Slack.app"
      # ];
    };
  };

  # Environment configuration for proper terminal integration
  environment = {
    variables = {
      # Terminal identification for applications
      TERM_PROGRAM = "kitty"; # Identify kitty as the terminal program
      TERMINAL = "kitty"; # Set kitty as default terminal for CLI tools
    };

    # Terminal information database
    # This option will be available in future NixOS releases
    # Currently using kitty.terminfo package in base modules as workaround
    # enableAllTerminfo = true; # Enable when upgrading from 25.05
  };
}
