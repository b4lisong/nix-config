{ config, lib, pkgs, ... }:

{
  /*
    Darwin (macOS) System Configuration
    
    This module contains configuration specific to macOS/Darwin systems.
    It builds upon the base configuration and adds macOS-specific features.
    
    Inheritance hierarchy:
    base/default.nix → systems/darwin/default.nix (this file) → hosts/darwin/*
    
    This configuration will be inherited by all Darwin/macOS hosts and can
    be overridden by individual host configurations as needed.
  */

  # Import the base configuration that all systems share
  imports = [
    ../../base/default.nix
  ];

  /*
    Darwin-Specific Nix Configuration
  */
  nix = {
    # Darwin-specific garbage collection schedule
    gc = {
      # Run garbage collection daily on macOS (more frequent than base config suggests)
      interval = { Hour = 3; Minute = 15; };  # 3:15 AM daily
    };
  };

  /*
    macOS System Fonts
    Install fonts system-wide for all users and applications
  */
  fonts.packages = with pkgs; [
    # Nerd Fonts for terminal and development
    nerd-fonts.sauce-code-pro
    nerd-fonts.symbols-only
    
    # Icon fonts for UI applications
    font-awesome
    material-design-icons
    
    # Emoji support
    noto-fonts-emoji
    
    # High-quality general fonts
    dejavu_fonts
  ];

  /*
    macOS System Settings and Preferences
    
    These settings configure the macOS user interface and system behavior.
    All options are documented at: https://nix-darwin.github.io/nix-darwin/manual/index.html
  */

  # Use TouchID for sudo authentication
  # Note: For DisplayLink users, run this command:
  # /usr/bin/defaults write ~/Library/Preferences/com.apple.security.authorization.plist ignoreArd -bool TRUE
  security.pam.services.sudo_local.touchIdAuth = true;

  # System version and state management
  system = {
    # Set the primary user for nix-darwin (required for user-specific options)
    primaryUser = config.myVars.user.username;

    # Track configuration changes for system updates
    configurationRevision = null;  # Will be set by flake
    
    # nix-darwin state version - don't change unless upgrading nix-darwin
    stateVersion = 6;

    # macOS system preferences and UI customization
    defaults = {
      # Login window customization
      loginwindow = {
        LoginwindowText = "おかえり、お兄ちゃん";  # Custom login message
      };

      # Menu bar clock settings
      menuExtraClock = {
        Show24Hour = true;  # Use 24-hour time format
      };

      # Dock configuration
      dock = {
        autohide = true;                    # Automatically hide dock when not in use
        show-recents = false;               # Don't show recent apps in dock
        mru-spaces = false;                 # Don't rearrange spaces by recent use
        expose-group-apps = true;           # Group windows by application in Exposé
        showhidden = true;                  # Show hidden applications in dock
        autohide-delay = 0.0;              # No delay before showing dock
        autohide-time-modifier = 0.2;      # Fast dock animation
        orientation = "bottom";             # Dock position
        tilesize = 48;                     # Icon size (16-128)
        magnification = true;              # Enable icon magnification on hover
        largesize = 64;                    # Magnified icon size
        minimize-to-application = true;     # Minimize windows into app icon
        
        # Default apps to keep in dock
        persistent-apps = [
          "/Applications/Safari.app"
          "/Applications/Cursor.app"
        ];
      };

      # Finder configuration
      finder = {
        _FXShowPosixPathInTitle = true;     # Show full POSIX path in title
        AppleShowAllExtensions = true;      # Show all file extensions
        FXEnableExtensionChangeWarning = false;  # No warning when changing extensions
        QuitMenuItem = true;                # Enable Finder quit menu item
        ShowPathbar = true;                 # Show path bar at bottom
        ShowStatusBar = true;               # Show status bar at bottom
        FXDefaultSearchScope = "SCcf";      # Search current folder by default
        FXPreferredViewStyle = "Nlsv";      # Default to list view
      };

      # Trackpad settings
      trackpad = {
        Clicking = true;                    # Enable tap-to-click
        TrackpadRightClick = true;          # Enable two-finger right click
        TrackpadThreeFingerDrag = true;     # Enable three-finger drag
      };

      # Control Center configuration
      controlcenter = {
        Sound = true;  # Show sound controls in menu bar
      };

      # Global macOS preferences
      NSGlobalDomain = {
        # Appearance and interface
        AppleInterfaceStyle = "Dark";       # Enable dark mode
        AppleKeyboardUIMode = 3;            # Full keyboard control
        
        # Keyboard behavior
        ApplePressAndHoldEnabled = true;    # Enable press and hold for accents
        InitialKeyRepeat = 15;              # Delay before key repeat (lower = faster)
        KeyRepeat = 2;                      # Key repeat rate (lower = faster)
        
        # File and dialog behavior
        AppleShowAllExtensions = true;      # Show file extensions everywhere
        AppleShowScrollBars = "Automatic";  # Show scroll bars when needed
        NSNavPanelExpandedStateForSaveMode = true;   # Expand save dialogs
        NSNavPanelExpandedStateForSaveMode2 = true;  # Expand save dialogs
        PMPrintingExpandedStateForPrint = true;      # Expand print dialogs
        PMPrintingExpandedStateForPrint2 = true;     # Expand print dialogs
        
        # Text input behavior
        NSAutomaticCapitalizationEnabled = false;    # Disable auto capitalization
        NSAutomaticDashSubstitutionEnabled = false;  # Disable smart dashes
        NSAutomaticPeriodSubstitutionEnabled = false;  # Disable auto periods
        NSAutomaticQuoteSubstitutionEnabled = false;   # Disable smart quotes
        NSAutomaticSpellingCorrectionEnabled = false;  # Disable auto spelling correction
      };

      # Mouse tracking speed
      ".GlobalPreferences"."com.apple.mouse.scaling" = 1.0;
    };
  };

  /*
    Homebrew Integration
    
    Homebrew is used for GUI applications that need proper macOS integration,
    especially those that require Spotlight indexing or system services.
  */
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # Remove undefined packages on activation
    
    # GUI applications installed via Homebrew casks
    casks = [
      "cursor"           # AI-powered code editor
      "scroll-reverser"  # Reverse scroll direction for mice
      "little-snitch"    # Network monitoring and firewall
    ];
    
    # Command-line tools via Homebrew (use sparingly - prefer Nix when possible)
    brews = [
      # Add here only if package isn't available in nixpkgs or has issues
    ];
    
    # Mac App Store applications
    masApps = {
      # Format: "App Name" = app-store-id;
      # Find IDs at: https://apps.apple.com/ (look at URL)
    };
  };

  /*
    Darwin User Configuration
    Add macOS-specific user account settings
  */
  users.users.${config.myVars.user.username} = {
    home = "/Users/${config.myVars.user.username}";
    # Additional Darwin-specific user settings can be added here
  };

  /*
    Darwin-Specific System Packages
    Packages that are specific to macOS or work better on Darwin
  */
  environment.systemPackages = with pkgs; [
    # Add Darwin-specific packages here if needed
    # Most packages should go in base or modules
  ];

  /*
    Platform Configuration
    Set the target platform for this Darwin system
    This will be overridden by individual hosts to specify their architecture
  */
  # nixpkgs.hostPlatform will be set by individual host configurations
  # to either "x86_64-darwin" or "aarch64-darwin"
}