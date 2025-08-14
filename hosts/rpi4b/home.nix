{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  vars,
  ...
}: {
  # Import user configuration layers based on TUI profile
  imports = [
    # Core profile with essential CLI tools
    ../../home/profiles/base
    
    # TUI profile - perfect for headless Raspberry Pi
    ../../home/profiles/tui
    
    # Development role for programming projects
    ../../home/roles/dev
  ];

  # Home Manager configuration
  home = {
    username = vars.user.username;
    homeDirectory = lib.mkForce "/home/${vars.user.username}";
    
    # Pi-specific packages for hardware projects and monitoring
    packages = with pkgs; [
      # System monitoring and hardware tools
      iotop          # I/O monitoring
      bandwhich      # Network utilization by process
      dust           # Disk usage analyzer
      procs          # Modern ps replacement
      
      # Hardware interaction tools
      minicom        # Serial communication
      picocom        # Another serial terminal
      i2c-tools      # I2C utilities for sensors
      
      # Network utilities for headless operation
      nmap           # Network scanning
      netcat-gnu     # Network debugging
      rsync          # File synchronization
      
      # Development tools for Pi projects
      gcc            # C compiler for hardware projects
      gdb            # Debugger
      python3        # Python for GPIO/sensor scripts
      
      # Text processing
      jq             # JSON processor
      yq             # YAML processor
      
      # Archive tools
      p7zip          # 7-zip support
      unrar          # RAR extraction
      
      # Git tools (extended from base profile)
      git-lfs        # Large file support
      
      # System utilities
      pciutils       # lspci
      usbutils       # lsusb
      file           # File type detection
      which          # Command location
    ] ++ [
      # Unstable packages for latest development tools
      pkgs-unstable.nodejs_latest  # Latest Node.js for modern JS projects
    ];
  };

  # Git configuration using centralized variables
  programs.git = {
    userName = vars.git.userName;
    userEmail = vars.git.userEmail;
  };

  # SSH client configuration for accessing other systems
  programs.ssh = {
    enable = true;
    compression = true;
    controlMaster = "auto";
    controlPersist = "10m";
    
    # Host configurations for common connections
    matchBlocks = {
      "*.local" = {
        user = vars.user.username;
        forwardAgent = false;
      };
    };
  };

  # Shell configuration optimized for Pi usage
  programs.zsh = {
    enable = true;
    
    # Pi-specific aliases and functions
    shellAliases = {
      # System monitoring shortcuts
      temp = "vcgencmd measure_temp";  # Pi temperature
      gpu-temp = "vcgencmd measure_temp";
      cpu-freq = "vcgencmd measure_clock arm";
      gpu-freq = "vcgencmd measure_clock core";
      
      # Quick system info
      pi-info = "vcgencmd version && vcgencmd get_mem arm && vcgencmd get_mem gpu";
      
      # GPIO shortcuts (if wiringPi or similar is installed)
      gpio-read = "gpio readall";
      
      # Network shortcuts for headless operation  
      myip = "curl -s ifconfig.me";
      localip = "ip route get 1 | head -1 | cut -d' ' -f7";
      
      # SD card health monitoring
      sd-health = "sudo smartctl -a /dev/mmcblk0";
    };
    
    # Additional environment variables for Pi development
    sessionVariables = {
      # Python path for Pi GPIO libraries
      PYTHONPATH = "$PYTHONPATH:/opt/vc/lib/python3.x/site-packages";
    };
  };

  # Tmux configuration for persistent sessions over SSH
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    
    # Pi-optimized tmux settings
    extraConfig = ''
      # Mouse support for easier navigation over SSH
      set -g mouse on
      
      # Increase history for debugging
      set -g history-limit 10000
      
      # Status bar with Pi-specific info
      set -g status-right "#[fg=green]#H #[fg=yellow]#{?window_zoomed_flag, 🔍 ,}#[fg=blue]%Y-%m-%d %H:%M"
      
      # Automatic session restoration
      set -g @resurrect-save-bash-history 'on'
      set -g @resurrect-capture-pane-contents 'on'
    '';
  };

  # Neovim configuration for development on Pi
  programs.neovim = {
    # Use lightweight configuration suitable for resource-constrained Pi
    extraLuaConfig = ''
      -- Pi-specific optimizations
      vim.opt.updatetime = 1000  -- Slower update for better performance
      vim.opt.timeoutlen = 500   -- Faster key timeout
      
      -- Disable heavy features for better Pi performance
      vim.g.loaded_perl_provider = 0
      vim.g.loaded_ruby_provider = 0
    '';
  };

  # Starship prompt with Pi-specific modules
  programs.starship = {
    settings = {
      # Show memory usage (important for Pi)
      memory_usage = {
        disabled = false;
        threshold = 70;
        format = "[$symbol$ram]($style) ";
        symbol = "🐏 ";
      };
      
      # Show hostname for SSH sessions
      hostname = {
        ssh_only = false;
        format = "on [$hostname](bold red) ";
        disabled = false;
      };
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. Don't change this after
  # the initial installation.
  home.stateVersion = "25.05";
}