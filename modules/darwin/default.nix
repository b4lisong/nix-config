/*
`modules/darwin/default.nix`
System-level configuration common to all Darwin/macOS hosts
Extends base system configuration in `modules/base.nix`
*/
{self, ...}: {
  imports = [
    ./homebrew.nix # Import default Homebrew configuration
  ];

  # Define security options
  security = {
    pam.services.sudo_local = {
      # Whether to enable managing /etc/pam.d/sudo_local with nix-darwin
      enable = true;
      # Enable Touch ID authentication for sudo
      # This allows using fingerprint authentication when running sudo commands
      touchIdAuth = true;
    };
  };

  # Allow unfree packages for all Darwin systems
  nixpkgs.config.allowUnfree = true;

  system = {
    # System state version for nix-darwin compatibility
    # This tracks the nix-darwin configuration format version
    # Increment only when making breaking changes to the system configuration
    stateVersion = 6;

    # Git revision tracking for reproducible builds
    # Shows which commit was used to build this configuration
    configurationRevision = self.rev or self.dirtyRev or null;

    # macOS system preferences and defaults
    # These settings configure the native macOS user interface and behavior
    defaults = {
      # Menu bar configuration
      menuExtraClock.Show24Hour = true; # Use 24-hour time format in menu bar

      # Dock behavior and appearance
      dock = {
        autohide = true; # Hide dock when not in use for more screen space
        show-recents = false; # Don't show recently used apps in dock
        mru-spaces = false; # Don't rearrange spaces based on usage
        expose-group-apps = true; # Group windows by application in Mission Control
        showhidden = true; # Show indicators for hidden applications
        autohide-delay = 0.0; # No delay before dock appears when cursor hovers
        autohide-time-modifier = 0.2; # Fast dock show/hide animation (0.2s)
        orientation = "bottom"; # Position dock at bottom of screen
        tilesize = 48; # Normal icon size in dock
        magnification = true; # Enable icon magnification on hover
        largesize = 64; # Maximum icon size when magnified
        minimize-to-application = true; # Minimize windows into app icon rather than dock
      };

      # Finder file manager configuration
      finder = {
        _FXShowPosixPathInTitle = true; # Show full POSIX path in Finder title bar
        AppleShowAllExtensions = true; # Always show file extensions
        FXEnableExtensionChangeWarning = false; # Don't warn when changing file extensions
        QuitMenuItem = true; # Enable Quit option in Finder menu
        ShowPathbar = true; # Show path bar at bottom of Finder windows
        ShowStatusBar = true; # Show status bar with file counts and storage info
        FXDefaultSearchScope = "SCcf"; # Search current folder by default (not entire Mac)
        FXPreferredViewStyle = "Nlsv"; # Use list view as default Finder view
      };

      # Trackpad gesture and behavior settings
      trackpad = {
        Clicking = true; # Enable tap to click
        TrackpadRightClick = true; # Enable two-finger right click
        TrackpadThreeFingerDrag = true; # Enable three-finger window dragging
      };

      # Mouse behavior
      ".GlobalPreferences"."com.apple.mouse.scaling" = 1.0; # Normal mouse tracking speed

      # Control Center configuration
      controlcenter.Sound = true; # Show sound controls in Control Center

      # Global system preferences (NSGlobalDomain affects all applications)
      NSGlobalDomain = {
        # Interface and appearance
        AppleInterfaceStyle = "Dark"; # Use dark mode system-wide
        AppleKeyboardUIMode = 3; # Full keyboard access for dialogs and controls
        ApplePressAndHoldEnabled = true; # Enable press-and-hold for accented characters
        NSWindowShouldDragOnGesture = true; # Move windows w/ctrl+cmd and drag

        # Keyboard repeat behavior
        InitialKeyRepeat = 15; # Delay before key repeat starts (15 = ~250ms)
        KeyRepeat = 2; # Key repeat rate (2 = ~30ms between repeats)

        # File and interface behavior
        AppleShowAllExtensions = true; # Show file extensions in all apps
        AppleShowScrollBars = "Automatic"; # Show scroll bars when needed

        # Dialog box behavior (expand by default)
        NSNavPanelExpandedStateForSaveMode = true; # Expand save dialogs
        NSNavPanelExpandedStateForSaveMode2 = true; # Expand save dialogs (newer apps)
        PMPrintingExpandedStateForPrint = true; # Expand print dialogs
        PMPrintingExpandedStateForPrint2 = true; # Expand print dialogs (newer apps)

        # Text input behavior (disable autocorrect features for development work)
        NSAutomaticCapitalizationEnabled = false; # Don't auto-capitalize
        NSAutomaticDashSubstitutionEnabled = false; # Don't convert -- to em dash
        NSAutomaticPeriodSubstitutionEnabled = false; # Don't add period after double-space
        NSAutomaticQuoteSubstitutionEnabled = false; # Don't convert quotes to curly quotes
        NSAutomaticSpellingCorrectionEnabled = false; # Don't auto-correct spelling

        # Font rendering
        AppleFontSmoothing = 1; # Minimal font smoothing for crisp text
      };
    };
  };

  # Darwin-wide system services
  services = {
    # JankyBorders - Adds colored borders around windows for visual focus indication
    # Particularly useful for window managers like yabai or when using multiple windows
    jankyborders = {
      enable = true; # Enable the JankyBorders service
      hidpi = true; # Enable high-DPI support for crisp borders on retina displays

      # Active window border: Green to blue gradient (top-left to bottom-right)
      # Uses Catppuccin color scheme - a6e3a1 (green) to 89b4fa (blue)
      active_color = "gradient(top_left=0xffa6e3a1,bottom_right=0xff89b4fa)";

      # Inactive window border: Dark gray from Catppuccin base theme (1e1e2e)
      # Low opacity (0x00) makes it very subtle for inactive windows
      inactive_color = "0x001e1e2e";

      # Layer order: Draw borders above window content for better visibility
      order = "above";
    };
  };

  # Add extra directories to PATH
  environment.systemPath = [
    "$HOME/.local/bin"
    "$HOME/.local/npm-global/bin"
  ];
}
