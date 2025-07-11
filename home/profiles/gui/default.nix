/*
`home/profiles/gui/default.nix`
Desktop/GUI applications profile for cross-platform use

This profile provides the foundation for graphical desktop environments
by importing the TUI profile and adding GUI-specific applications and
configurations. It serves as a base for desktop systems across platforms.

Architecture:
- Inherits all CLI tools and utilities from ../tui profile
- Adds cross-platform GUI applications
- Provides baseline kitty terminal configuration
- Intended to be extended by platform-specific profiles (like darwin)

Usage:
- Imported by platform-specific GUI profiles (profiles/darwin)
- Can also be imported directly by hosts that need cross-platform GUI
- Forms the middle layer: base → tui → gui → platform-specific

This profile focuses on applications that work consistently across
Linux and macOS, avoiding platform-specific implementations.
*/
{pkgs, ...}: {
  imports = [
    ../tui # Import TUI profile for CLI foundation
    ../../modules/terminal/kitty.nix # Cross-platform kitty terminal baseline
  ];

  home.packages = with pkgs; [
    # Cross-platform GUI applications
    # These packages should work consistently on both Linux and macOS

    # Web browsers (cross-platform versions)
    # firefox # Uncomment when needed

    # Development tools with GUI
    # vscode # Uncomment when needed - prefer platform-specific variants

    # Media and graphics
    # vlc # Uncomment when needed
    # gimp # Uncomment when needed

    # Communication
    # discord # Uncomment when needed
    # slack # Uncomment when needed

    # Utilities
    # keepassxc # Password manager
    # obs-studio # Screen recording/streaming

    # Note: Platform-specific applications (like Mac App Store apps)
    # should be defined in platform-specific profiles (profiles/darwin)
    # or in host-specific configurations
  ];

  # Cross-platform GUI program configurations
  # These settings should work on both Linux and macOS
  programs = {
    # Example GUI program configuration
    # firefox = {
    #   enable = true;
    #   # Cross-platform Firefox settings
    # };
  };
}
