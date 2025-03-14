{pkgs, ...}: {
  ##########################################################################
  #
  #  Install all common apps and packages here.
  #
  #  NOTE: Your can find all available options in:
  #    https://daiderd.com/nix-darwin/manual/index.html
  #
  #  Host-specific applications defined in:
  #    hosts/{host}/apps.nix
  #
  ##########################################################################

  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    git
    exiftool
  ];

  # System services
  services = {
    jankyborders = {
      enable = true;
      active_color = "gradient(top_right=0xffa6e3a1,bottom_left=0xff89b4fa)";
      inactive_color = "0x33585b70";
      hidpi = true;
      width = 5.0;
    };
  };

  # TODO To make this work, homebrew need to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      cleanup = "zap";
    };

    taps = [
      "homebrew/services"
      "nikitabobko/tap" # for Aerospace
    ];

    # `brew install`
    # TODO Feel free to add your favorite apps here.
    brews = [
      # "aria2"  # download tool
    ];

    # `brew install --cask`
    # TODO Feel free to add your favorite apps here.
    casks = [
      # Password Managers
      "1password@beta"
      "1password-cli"

      # Browsers
      "google-chrome"
      "firefox"

      # Security
      "little-snitch"

      # Virtualization
      "vmware-fusion"

      # RDP
      "parsec"

      # UI
      "scroll-reverser"
      "nikitabobko/tap/aerospace"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
      "Tailscale" = 1475387142;
      "Windows App" = 1295203466;
    };
  };
}
