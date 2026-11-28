/*
`hosts/darwin-m5mba/default.nix`
System-level configuration for the m5mba host

Personal MacBook Air 15" (M5, early 2026), aarch64-darwin. Successor to
a2251 (Intel MacBook Pro); this configuration started as a copy of it.

base.nix and modules/darwin are imported by outputs/aarch64-darwin/src/m5mba.nix,
which also sets nixpkgs.hostPlatform. Settings here extend those modules.
*/
{myvars, ...}: {
  system = {
    primaryUser = myvars.user.username;
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };

  users.users.${myvars.user.username} = {
    name = myvars.user.username;
    home = "/Users/${myvars.user.username}";
  };

  # Extends the defaults in modules/darwin/homebrew.nix.
  homebrew = {
    casks = [
      # Development
      "visual-studio-code"
      "claude" # Claude Desktop
      "claude-code"
      "codex" # OpenAI Codex CLI
      "codex-app" # OpenAI Codex desktop app

      # Remote access and virtualization
      "parsec" # Low-latency remote desktop
      "orbstack" # Docker and Linux VMs

      # Browsers
      "google-chrome"

      # Communication
      "discord"

      # Password management
      "1password"

      # Networking
      "tailscale-app"

      # Utilities
      "caffeine" # Keep the Mac awake
      "balenaetcher" # Write OS images to USB/SD
      "displaylink" # DisplayLink dock driver; approve its extension after install

      # Notes
      "obsidian" # nixpkgs build is unavailable on aarch64-darwin
    ];

    brews = [
      "herdr" # Terminal multiplexer for coding agents
    ];

    # Requires signing into the App Store before the first activation.
    masApps = {
      "1Password for Safari" = 1569813296;
    };
  };

  system.defaults.loginwindow.LoginwindowText = "おかえり、お兄ちゃん";

  environment.variables = {
    TERM_PROGRAM = "kitty";
    TERMINAL = "kitty";
  };
}
