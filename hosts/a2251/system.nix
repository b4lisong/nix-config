_: let
  vars = import ../../variables;
in {
  imports = [
    ../../modules/base.nix
    ../../modules/darwin
  ];

  nixpkgs.hostPlatform = vars.hosts.a2251.system;

  system.primaryUser = vars.user.username;

  users.users.${vars.user.username} = {
    name = vars.user.username;
    home = "/Users/${vars.user.username}";
  };

  # Host-specific Homebrew configuration
  # This extends the defaults from `modules/darwin/homebrew.nix`
  homebrew = {
    # Inherit defaults from modules/darwin and extend casks
    casks = [
      # Keep the default casks from `modules/darwin/homebrew.nix`
      # Add host-specific casks
      "cursor" # AI-powered code editor
      "parsec" # Remote desktop
      "vmware-fusion" # Virtualization
      "wine@staging" # Windows exe compatibility layer
    ];
    brews = [
      "winetricks" # Work around Wine problems
    ];
    masApps = {
    };
  };

  system.defaults = {
    loginwindow.LoginwindowText = "おかえり、お兄ちゃん";
    dock = {
      # persistent-apps = [
      #   "/Applications/Safari.app"
      #   "/Applications/Cursor.app"
      # ];
    };
  };

  environment = {
    variables = {
      # Ensure proper terminal behavior
      TERM_PROGRAM = "kitty";
      # Set kitty as default terminal for command-line tools
      TERMINAL = "kitty";
    };
    # This option is available, but not in the 25.05 release
    # Enable this once we migrate/upgrade from 25.05
    # For now, we'll add `kitty.terminfo` to the base modules
    # enableAllTerminfo = true;
  };
}
