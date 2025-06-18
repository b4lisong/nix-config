/*
Default Homebrew configuration for all Darwin systems
This module provides sensible defaults while allowing hosts to override and extend
*/
{ lib, ... }:

{
  homebrew = {
    enable = lib.mkDefault true;
    
    # Conservative activation settings for reliability
    onActivation = {
      cleanup = lib.mkDefault "zap";     # Remove unused packages completely
      autoUpdate = lib.mkDefault false;  # Don't auto-update during rebuild
      upgrade = lib.mkDefault false;     # Don't auto-upgrade packages
    };

    # Homebrew packages for all Darwin/macOS systems
    casks = [
      # System utilities
      "scroll-reverser"  # Fix mouse scroll direction
      "little-snitch"    # Network monitoring and security
      
      # Could add more universally useful defaults:
      "raycast"        # Spotlight replacement
      # "1password"      # Password manager
      # "cleanmymac"     # System maintenance
    ];

    # Command-line tools that most developers need
    brews = [
      # Could add more universal CLI tools:
      # "gh"           # GitHub CLI
      # "git-lfs"      # Git Large File Storage
      # "ffmpeg"       # Media processing
    ];

    # Mac App Store apps (conservative defaults)
    masApps = {
      # Could add essential Mac App Store apps:
      # "Xcode" = 497799835;              # For iOS/macOS development
      # "Amphetamine" = 937984704;        # Keep Mac awake
    };

    # Global Homebrew configuration
    global = {
      brewfile = lib.mkDefault true;     # Use nix-darwin generated Brewfile
      lockfiles = lib.mkDefault false;   # Don't create lockfiles (read-only store)
      autoUpdate = lib.mkDefault true;   # Allow manual brew commands to auto-update
    };

    # Tap configuration (add commonly needed taps)
    taps = lib.mkDefault [
    ];
  };
}