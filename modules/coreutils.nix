{ config, lib, pkgs, ... }:

{
  /*
    Core Utilities Module
    
    This module provides essential command-line tools and utilities that
    enhance the basic Unix/Linux experience.
    
    Included categories:
    - Modern replacements for classic Unix tools
    - File and directory utilities
    - Text processing and search tools
    - System monitoring and process management
    - Archive and compression tools
    - Network utilities
    
    Usage:
      Import this module in any host configuration that needs
      a rich command-line environment.
  */

  environment.systemPackages = with pkgs; [
    # Modern replacements for classic Unix tools
    bat               # Better 'cat' with syntax highlighting
    eza               # Better 'ls' with git integration and colors
    fd                # Better 'find' - faster and more user-friendly
    ripgrep           # Better 'grep' - much faster recursive search
    zoxide            # Better 'cd' with intelligent path jumping
    
    # File and directory utilities
    tree              # Display directory structure as tree
    file              # Determine file types
    which             # Locate commands
    rsync             # Efficient file synchronization
    
    # Text processing and manipulation
    jq                # JSON processor and formatter
    yq                # YAML/XML processor (like jq for YAML)
    sed               # Stream editor
    awk               # Text processing language
    
    # System monitoring and process management
    htop              # Interactive process viewer (better than top)
    btop              # Modern resource monitor with great UI
    lsof              # List open files and network connections
    killall           # Kill processes by name
    
    # Archive and compression
    p7zip             # 7-Zip archiver
    unrar             # RAR archive extraction
    gzip              # Gzip compression
    bzip2             # Bzip2 compression
    
    # Network utilities
    wget              # File downloader
    curl              # HTTP client and file transfer
    nmap              # Network discovery and security auditing
    dig               # DNS lookup utility
    
    # Development and productivity
    tmux              # Terminal multiplexer
    
    # Miscellaneous utilities
    ncdu              # NCurses disk usage analyzer
    tldr              # Simplified man pages with practical examples
    fzf               # Fuzzy finder for command line
  ];

  /*
    Shell Integration and Aliases
    
    Configure shell aliases that work well with the modern tools above.
    These aliases provide a better default experience while maintaining
    compatibility with standard Unix commands.
  */
  programs.zsh.shellAliases = lib.mkMerge [
    # Modern tool replacements (only if tools are available)
    (lib.mkIf (builtins.elem pkgs.bat config.environment.systemPackages) {
      cat = "bat --paging=never";  # Use bat but don't page for small files
    })
    
    (lib.mkIf (builtins.elem pkgs.eza config.environment.systemPackages) {
      ls = "eza --icons";          # Use eza with icons
      ll = "eza -l --icons";       # Long format with icons
      la = "eza -la --icons";      # Long format with hidden files
      tree = "eza --tree";         # Tree view using eza
    })
    
    (lib.mkIf (builtins.elem pkgs.fd config.environment.systemPackages) {
      find = "fd";                 # Use fd as find replacement
    })
    
    # Useful shortcuts regardless of available tools
    {
      # Quick directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      
      # Safety aliases
      rm = "rm -i";               # Prompt before removing files
      cp = "cp -i";               # Prompt before overwriting files
      mv = "mv -i";               # Prompt before overwriting files
      
      # Convenience aliases
      h = "history";
      j = "jobs -l";
      grep = "grep --color=auto";
      
      # System information
      ports = "lsof -i";          # Show what's using network ports
      psg = "ps aux | grep";      # Search running processes
    }
  ];

  /*
    Environment Variables
    
    Set up environment variables that enhance the experience
    with the tools provided by this module.
  */
  environment.variables = {
    # Better paging with bat
    PAGER = lib.mkIf (builtins.elem pkgs.bat config.environment.systemPackages) "bat";
    
    # Enable colored output for various tools
    CLICOLOR = "1";
    
    # Configure ripgrep
    RIPGREP_CONFIG_PATH = pkgs.writeText "ripgreprc" ''
      # Use smart case (case insensitive unless pattern contains uppercase)
      --smart-case
      
      # Show line numbers
      --line-number
      
      # Don't search in git directories, node_modules, etc.
      --glob=!.git/*
      --glob=!node_modules/*
      --glob=!target/*
      --glob=!*.lock
    '';
  };

  /*
    Program Configuration
    
    Configure programs that are included in this module for optimal
    out-of-the-box experience.
  */
  programs = {
    # Enable zoxide (smart cd replacement)
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    
    # Configure fzf (fuzzy finder)
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f";  # Use fd instead of find
      defaultOptions = [
        "--height 40%"
        "--border"
        "--layout=reverse"
        "--inline-info"
      ];
    };
  };
}