{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  myvars,
  ...
}: {
  # Import user configuration layers for minimal Pi setup
  imports = [
    # TUI profile - includes base profile with essential CLI tools
    ../../home/profiles/tui
  ];

  # Home Manager configuration
  home = {
    username = myvars.user.username;
    homeDirectory = lib.mkForce "/home/${myvars.user.username}";

    # Minimal host-specific packages
    packages = with pkgs; [
      # Pi-specific monitoring (vcgencmd comes with libraspberrypi in system config)
      smartmontools # SD card health monitoring (smartctl)
    ];
  };

  # Git configuration using centralized variables
  programs.git = {
    userName = myvars.git.userName;
    userEmail = myvars.git.userEmail;
  };

  # Pi-specific shell configuration
  programs.zsh = {
    # Raspberry Pi Zero 2 W specific aliases and functions
    shellAliases = {
      # Pi-specific system monitoring shortcuts
      temp = "vcgencmd measure_temp 2>/dev/null || echo 'vcgencmd not available'";
      cpu-freq = "vcgencmd measure_clock arm 2>/dev/null || echo 'vcgencmd not available'";

      # Pi system information
      pi-info = "vcgencmd version 2>/dev/null && vcgencmd get_mem arm 2>/dev/null && vcgencmd get_mem gpu 2>/dev/null || echo 'Pi-specific commands not available'";

      # Network shortcuts
      myip = "curl -s ifconfig.me";
      localip = "ip route get 1 | head -1 | cut -d' ' -f7";

      # SD card health monitoring specific to Pi
      sd-health = "sudo smartctl -a /dev/mmcblk0 2>/dev/null || echo 'SD card monitoring not available'";
    };
  };

  # Neovim configuration optimized for Pi Zero 2 W performance
  programs.neovim = {
    # Pi Zero 2 W specific performance optimizations
    extraLuaConfig = ''
      -- Pi Zero 2 W specific optimizations (less powerful than Pi 4B)
      vim.opt.updatetime = 2000  -- Slower update for better performance on Pi Zero
      vim.opt.timeoutlen = 500   -- Faster key timeout

      -- Disable heavy features for better Pi performance
      vim.g.loaded_perl_provider = 0
      vim.g.loaded_ruby_provider = 0
    '';
  };

  # Starship prompt customization for this Pi
  programs.starship = {
    settings = {
      # Show memory usage (critical for Pi monitoring)
      memory_usage = {
        disabled = false;
        threshold = 70; # Pi Zero 2 W has limited RAM
        format = "[$symbol$ram]($style) ";
        symbol = "MEM ";
      };

      # Always show hostname for this headless Pi
      hostname.disabled = false;
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. Don't change this after
  # the initial installation.
  home.stateVersion = "25.05";
}
