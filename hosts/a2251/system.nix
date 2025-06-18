{
  pkgs,
  lib,
  self,
  vars,
  ...
}: let
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
      "spotify"
      "burp-suite"
      "firefox"
    ];
    brews = [
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
}
