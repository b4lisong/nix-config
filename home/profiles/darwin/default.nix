/*
`home/profiles/darwin/default.nix`
Complete macOS/Darwin Home Manager profile

This profile provides the complete Darwin desktop experience by building upon
the cross-platform GUI profile and adding macOS-specific enhancements and
optimizations. It represents the top layer of the profile hierarchy for macOS systems.

Profile Architecture (bottom to top):
- base: Core CLI tools and configurations
- tui: Additional terminal utilities and TUI applications
- gui: Cross-platform desktop applications and configurations
- darwin: macOS-specific applications, optimizations, and integrations (this file)

Purpose:
- Serves as the complete desktop profile for macOS hosts
- Adds macOS-specific application variants and system integrations
- Provides platform-optimized configurations (fonts, DPI, etc.)
- Includes macOS-native applications and features

Usage:
- Imported by macOS hosts that need the full desktop experience
- Automatically includes all lower-level profiles (gui → tui → base)
- Combined with role modules (dev, personal, work) for complete environments
- Represents the standard macOS user environment in this configuration

Darwin-Specific Features:
- macOS-optimized kitty terminal configuration
- Higher DPI font sizes and spacing for Retina displays
- Native macOS keyboard shortcuts and behaviors
- Integration with macOS system services and notifications
- Support for Mac-specific applications (App Store, system utilities)

Extension Points:
- Additional Darwin-specific modules can be added to imports
- Platform-specific application configurations
- macOS system integration modules
- Performance optimizations for Apple hardware
*/
{...}: {
  imports = [
    # Import cross-platform GUI baseline (includes tui and base profiles)
    ../gui

    # Add Darwin-specific enhancements and integrations
    ../../modules/terminal/kitty-darwin.nix # macOS-optimized kitty configuration

    # Future Darwin-specific modules can be added here:
    # ../../modules/editors/vscode-darwin.nix    # macOS-specific VSCode settings
    # ../../modules/browsers/firefox-darwin.nix  # macOS Firefox optimizations
    # ../../modules/media/spotify-darwin.nix     # macOS Spotify integration
    # ../../modules/desktop/macos-defaults.nix   # System defaults and preferences
    # ../../modules/productivity/raycast.nix     # macOS productivity tools
    # ../../modules/development/xcode-tools.nix  # Apple development tools
  ];

  # Darwin-specific program configurations
  # These override or extend the cross-platform configurations from ../gui
  programs = {
    # Example Darwin-specific program overrides
    # kitty font size is already handled by kitty-darwin.nix
    # Additional macOS-specific configurations can be added here
  };

  # Darwin-specific environment variables
  home.sessionVariables = {
    # Ensure proper macOS integration
    # These are set automatically by the system, but can be overridden if needed
  };
}
