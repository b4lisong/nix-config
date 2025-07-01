/*
`hosts/a2251/system.nix`
System-level configuration for the a2251 host

This file defines the macOS system configuration for the a2251 host,
which is the personal MacBook Pro (Intel x86_64). It extends the base
Darwin configuration with host-specific settings and applications.

Host Information (from variables/default.nix):
- Hostname: a2251
- Architecture: x86_64-darwin (Intel MacBook Pro)
- Description: Personal MacBook Pro (Intel)
- Purpose: Primary development and personal machine

Architecture Flow:
1. Imports base.nix (shared packages, fonts, Nix settings)
2. Imports modules/darwin (macOS-specific system configuration)
3. Applies host-specific overrides and extensions
4. Integrates with Home Manager through flake.nix

Configuration Areas:
- Host platform and user setup
- Homebrew packages specific to this machine
- macOS system defaults and preferences
- Environment variables for terminal integration
- Host-specific system behavior customizations
*/
_: let
  vars = import ../../variables;
in {
  imports = [
    ../../modules/base.nix # Shared system packages and Nix configuration
    ../../modules/darwin # macOS-specific system configuration and defaults
  ];

  # Set the target platform for this host (Intel MacBook Pro)
  nixpkgs.hostPlatform = vars.hosts.a2251.system;

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
  # with applications specific to this personal development machine
  homebrew = {
    # Inherit defaults from modules/darwin and extend with host-specific packages
    casks = [
      # Development and productivity tools
      "cursor" # AI-powered code editor for development work

      # Remote access and virtualization
      "parsec" # Low-latency remote desktop for gaming/work
      "vmware-fusion" # Virtualization for testing different OS environments

      # Compatibility and gaming
      "wine@staging" # Windows application compatibility layer

      # Browsers
      "google-chrome" # Chrome browser (not available in nixpkgs)
    ];

    # Command-line tools via Homebrew
    brews = [
      "winetricks" # Helper tool for Wine Windows compatibility
    ];

    # Mac App Store applications (none currently needed)
    masApps = {
      # Future Mac App Store apps can be added here with their IDs
      # Example: "Xcode" = 497799835;
    };
  };

  # macOS system defaults and preferences specific to this host
  system.defaults = {
    # Custom login window text (personal touch)
    loginwindow.LoginwindowText = "おかえり、お兄ちゃん";

    # Dock configuration
    dock = {
      # Persistent applications in dock (currently disabled)
      # These can be enabled for frequently used applications
      # persistent-apps = [
      #   "/Applications/Safari.app"
      #   "/Applications/Cursor.app"
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
