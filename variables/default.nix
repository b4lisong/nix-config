{
  /*
  Shared Variables and Constants

  This file contains configuration values that are used across multiple
  parts of the system. By centralizing these values, we ensure consistency
  and make it easy to update global preferences.

  These variables are designed to be imported and used throughout the
  configuration hierarchy (base → systems → hosts).
  */

  # Primary user configuration
  user = {
    username = "balisong";
    fullName = "balisong";
    shell = "zsh";
  };

  # Git configuration
  git = {
    defaultBranch = "main";
    userName = "b4lisong";
    userEmail = "5397809+b4lisong@users.noreply.github.com";
    pullRebase = true;
  };

  # System preferences
  system = {
    timeZone = "America/Los_Angeles"; # Adjust for your timezone
    locale = "en_US.UTF-8";
  };

  # Editor and terminal preferences
  preferences = {
    editor = "vim";
    terminal = "kitty"; # Can be overridden per host
    colorScheme = "catppuccin-mocha";
  };

  # Host-specific information
  hosts = {
    a2251 = {
      hostname = "a2251";
      system = "x86_64-darwin";
      description = "Personal MacBook Pro (Intel)";
    };

    sksm3 = {
      hostname = "sksm3";
      system = "aarch64-darwin";
      description = "Work MacBook";
    };

    rpi4b = {
      hostname = "rpi4b";
      system = "aarch64-linux";
      description = "Raspberry Pi 4B";
    };

    x1c4g = {
      hostname = "x1c4g";
      system = "x86_64-linux";
      description = "X1 Carbon 4G";
    };
  };

  # Common directory paths
  paths = {
    configDir = "~/.config";
    cacheDir = "~/.cache";
  };
}
