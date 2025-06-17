{ pkgs, lib, self, vars, ... }:

let vars = import ../../variables;
in {
  imports = [
    ../../modules/base.nix
    ../../modules/darwin
  ];

  nixpkgs.hostPlatform = vars.hosts.a2251.system;
  nixpkgs.config.allowUnfree = true;

  system.primaryUser = vars.user.username;

  users.users.${vars.user.username} = {
    name = vars.user.username;
    home = "/Users/${vars.user.username}";
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [ "cursor" "scroll-reverser" "little-snitch" ];
    brews = [ ];
    masApps = { };
  };

  system.configurationRevision = self.rev or self.dirtyRev or null;

  system.defaults = {
    loginwindow.LoginwindowText = "おかえり、お兄ちゃん";
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
      persistent-apps = [
        "/Applications/Safari.app"
        "/Applications/Cursor.app"
      ];
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
    };
  };
}
