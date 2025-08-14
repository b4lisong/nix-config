{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  vars,
  ...
}: {
  # Import user configuration layers for Pi development setup
  imports = [
    # Core profile with essential CLI tools
    ../../home/profiles/base
    
    # TUI profile - perfect for headless Raspberry Pi
    ../../home/profiles/tui
    
    # Development role for programming projects
    ../../home/roles/dev
    
    # Embedded systems and hardware development role
    ../../home/roles/embedded
  ];

  # Home Manager configuration
  home = {
    username = vars.user.username;
    homeDirectory = lib.mkForce "/home/${vars.user.username}";
    
    # Host-specific packages for this particular Pi
    packages = with pkgs; [
      # Pi-specific monitoring (vcgencmd comes with libraspberrypi in system config)
      smartmontools    # SD card health monitoring (smartctl)
      
      # Additional development tools for this Pi instance
      ] ++ [
      # Latest development tools
      pkgs-unstable.nodejs_latest  # Latest Node.js for modern JS projects
    ];
  };

  # Git configuration using centralized variables
  programs.git = {
    userName = vars.git.userName;
    userEmail = vars.git.userEmail;
  };

  # Pi-specific shell configuration
  programs.zsh = {
    # Raspberry Pi specific aliases and functions
    shellAliases = {
      # Pi-specific system monitoring shortcuts
      temp = "vcgencmd measure_temp 2>/dev/null || echo 'vcgencmd not available'";
      gpu-temp = "vcgencmd measure_temp 2>/dev/null || echo 'vcgencmd not available'";
      cpu-freq = "vcgencmd measure_clock arm 2>/dev/null || echo 'vcgencmd not available'";
      gpu-freq = "vcgencmd measure_clock core 2>/dev/null || echo 'vcgencmd not available'";
      
      # Pi system information
      pi-info = "vcgencmd version 2>/dev/null && vcgencmd get_mem arm 2>/dev/null && vcgencmd get_mem gpu 2>/dev/null || echo 'Pi-specific commands not available'";
      
      # Network shortcuts optimized for this Pi's typical usage
      myip = "curl -s ifconfig.me";
      localip = "ip route get 1 | head -1 | cut -d' ' -f7";
      
      # SD card health monitoring specific to Pi
      sd-health = "sudo smartctl -a /dev/mmcblk0 2>/dev/null || echo 'SD card monitoring not available'";
    };
  };

  # Neovim configuration optimized for this Pi's performance
  programs.neovim = {
    # Pi-specific performance optimizations
    extraLuaConfig = ''
      -- Pi 4B specific optimizations
      vim.opt.updatetime = 1000  -- Slower update for better performance on Pi
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
        threshold = 70;  # Pi 4B has limited RAM
        format = "[$symbol$ram]($style) ";
        symbol = "🐏 ";
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