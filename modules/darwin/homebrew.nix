/*
Default Homebrew configuration for all Darwin systems
This module provides sensible defaults while allowing hosts to override and extend
*/
{
  config,
  lib,
  ...
}: let
  inherit (config.homebrew) prefix;
in {
  # nix-darwin builds PATH itself, so the /etc/paths.d/homebrew entry written
  # by the Homebrew installer is never read. Add the prefix (derived from the
  # platform: /opt/homebrew on Apple Silicon, /usr/local on Intel) after the
  # Nix profiles so Nix packages take precedence over Homebrew formulae, but
  # before the macOS system directories (nix-darwin adds those at order 1200)
  # so formulae still win over Apple's bundled tools. That matches where
  # /usr/local/bin, already on the default PATH, puts Intel Homebrew.
  environment.systemPath = lib.mkIf (config.homebrew.enable && prefix != "/usr/local") (lib.mkOrder 1100 [
    "${prefix}/bin"
    "${prefix}/sbin"
  ]);

  homebrew = {
    enable = lib.mkDefault true;

    # Conservative activation settings for reliability
    onActivation = {
      # Leave Homebrew packages that are not in the generated Brewfile alone.
      # "zap" removed 13 undeclared formulae on activation and kept failing on
      # casks it could not remove (gstreamer-runtime is a dependency of the
      # then-declared wine@staging), so packages installed by hand outside this
      # config were being deleted. Use "check" to preview removals instead.
      cleanup = lib.mkDefault "none";
      autoUpdate = lib.mkDefault false; # Don't auto-update during rebuild
      upgrade = lib.mkDefault false; # Don't auto-upgrade packages
    };

    # Homebrew packages for all Darwin/macOS systems
    casks = [
      # System utilities
      "scroll-reverser" # Fix mouse scroll direction
      "little-snitch" # Network monitoring and security

      # Terminal; configured by programs.kitty in home/modules/terminal
      "kitty"

      # Communication
      # Secure messaging. nixpkgs replaced the signal-desktop-bin binary package
      # with a build-from-source signal-desktop, whose signal-webrtc dependency
      # does not compile on Darwin (third_party/nasm includes the glibc-only
      # <endian.h>).
      "signal"

      # Could add more universally useful defaults:
      "raycast" # Spotlight replacement
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
      brewfile = lib.mkDefault true; # Use nix-darwin generated Brewfile
      autoUpdate = lib.mkDefault true; # Allow manual brew commands to auto-update
    };

    # Tap configuration (add commonly needed taps)
    taps =
      lib.mkDefault [
      ];
  };
}
