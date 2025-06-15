{ config, lib, pkgs, ... }:

{
  /*
    Core Utilities Module
    
    This module provides essential command-line tools and utilities that
    enhance the basic Unix/Linux experience. These are tools that most
    users would want on any system they actively use.
    
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
    screen            # Terminal multiplexer (alternative to tmux)
    
    # Miscellaneous utilities
    ncdu              # NCurses disk usage analyzer
    tldr              # Simplified man pages with practical examples
    fzf               # Fuzzy finder for command line
  ];

  /*
    Environment Variables
    
    Set up environment variables that enhance the experience
    with the tools provided by this module.
  */
  environment.variables = {
    # Better paging with bat
    PAGER = "bat";
    
    # Enable colored output for various tools
    CLICOLOR = "1";

    # Configure ripgrep (convert derivation to string path)
    RIPGREP_CONFIG_PATH = "${pkgs.writeText "ripgreprc" ''
      # Use smart case (case insensitive unless pattern contains uppercase)
      --smart-case
      
      # Show line numbers
      --line-number
      
      # Don't search in git directories, node_modules, etc.
      --glob=!.git/*
      --glob=!node_modules/*
      --glob=!target/*
      --glob=!*.lock
    ''}";  
  };

  /*
    Future: Shell Integration and Configuration
    
    For now, we'll rely on the packages being available and users can
    set up aliases manually or via Home Manager. Once we get the basic
    configuration working, we can add shell integration back.
  */
  
  # Note: Shell aliases and integration will be added later once we confirm
  # the basic module system is working properly.
}