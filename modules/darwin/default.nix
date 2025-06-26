/*
`modules/darwin/default.nix`
System-level configuration common to all Darwin/macOS hosts
Extends base system configuration in `modules/base.nix`
*/
{self, ...}: {
  imports = [
    ./homebrew.nix # Import default Homebrew configuration
  ];

  # Enable Touch ID authentication for sudo
  # This allows using fingerprint authentication when running sudo commands
  security.pam.services.sudo_local.touchIdAuth = true;

  # Allow unfree packages for all Darwin systems
  nixpkgs.config.allowUnfree = true;

  system = {
    # System state version for compatibility
    # This should be incremented when making breaking changes to the system configuration
    stateVersion = 6;

    configurationRevision = self.rev or self.dirtyRev or null;

    defaults = {
      menuExtraClock.Show24Hour = true;
      dock = {
        autohide = true;
        show-recents = false;
        mru-spaces = false;
        expose-group-apps = true;
        showhidden = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.2;
        orientation = "bottom";
        tilesize = 48;
        magnification = true;
        largesize = 64;
        minimize-to-application = true;
      };
      finder = {
        _FXShowPosixPathInTitle = true;
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "Nlsv";
      };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };
      ".GlobalPreferences"."com.apple.mouse.scaling" = 1.0;
      controlcenter.Sound = true;
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "Automatic";
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        AppleFontSmoothing = 1;
      };

      universalaccess = {
        reduceMotion = true;
      };
    };

    
  };
}
