/*
`hosts/sksm3/system.nix`
System-level configuration for the sksm3 host

This file defines the macOS system configuration for the sksm3 host,
which is the work MacBook (Apple Silicon). It extends the base
Darwin configuration with host-specific settings and applications
appropriate for a professional work environment (probably).

Host Information (from variables/default.nix):
- Hostname: sksm3
- Architecture: aarch64-darwin (Apple Silicon MacBook)
- Description: Work MacBook
- Purpose: Professional development and work machine

Architecture Flow:
1. Imports base.nix (shared packages, fonts, Nix settings)
2. Imports modules/darwin (macOS-specific system configuration)
3. Applies host-specific overrides and extensions
4. Integrates with Home Manager through flake.nix

Configuration Areas:
- Host platform and user setup
- macOS system defaults and preferences
- Environment variables for terminal integration
*/
_: let
  vars = import ../../variables;
in {
  imports = [
    ../../modules/base.nix # Shared system packages and Nix configuration
    ../../modules/darwin # macOS-specific system configuration and defaults
  ];

  # Set the target platform for this host (Apple Silicon MacBook)
  nixpkgs.hostPlatform = vars.hosts.sksm3.system;

  # Manage system settings
  system = {
    # Configure the primary user for this system
    primaryUser = vars.user.username;
    # Manage keyboard settings
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true; # More useful Caps Lock functionality (vim, etc.)
    };
  };

  # User account configuration
  users.users.${vars.user.username} = {
    name = vars.user.username;
    home = "/Users/${vars.user.username}";
  };

  # Host-specific Homebrew configuration
  # This extends the defaults from `modules/darwin/homebrew.nix`
  # with applications specific to this work development machine
  homebrew = {
    # Work-appropriate applications and tools
    casks = [
      # Development and productivity tools
      "cursor" # AI-powered code editor for development work
      "claude" # Claude Desktop MCP

      # Professional productivity
      "slack" # Team communication
      "zoom" # Video conferencing

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
