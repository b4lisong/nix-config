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
    Shell Integration and Configuration
    
    Configure shell integration for the tools since nix-darwin doesn't
    have extensive program configuration options.
  */
  programs.zsh = {
    # Modern tool aliases
    shellAliases = {
      # Modern tool replacements
      cat = "bat --paging=never";  # Use bat but don't page for small files
      ls = "eza --icons";          # Use eza with icons
      ll = "eza -l --icons";       # Long format with icons
      la = "eza -la --icons";      # Long format with hidden files
      tree = "eza --tree";         # Tree view using eza
      find = "fd";                 # Use fd as find replacement
      
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
    };
    
    # Shell initialization for tools that need setup
    interactiveShellInit = lib.mkAfter ''
      # Initialize zoxide (smart cd replacement)
      if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init zsh --cmd cd)"
      fi
      
      # Configure fzf if available
      if command -v fzf >/dev/null 2>&1; then
        # Set default command to use fd
        export FZF_DEFAULT_COMMAND="fd --type f"
        
        # Set default options
        export FZF_DEFAULT_OPTS="--height 40% --border --layout=reverse --inline-info"
        
        # Key bindings for fzf (try to source if available)
        for fzf_completion in \
          "/run/current-system/sw/share/fzf/completion.zsh" \
          "/usr/local/share/zsh/site-functions/_fzf" \
          "$(brew --prefix 2>/dev/null)/share/zsh/site-functions/_fzf" 2>/dev/null
        do
          if [[ -f "$fzf_completion" ]]; then
            source "$fzf_completion"
            break
          fi
        done
        
        for fzf_keybindings in \
          "/run/current-system/sw/share/fzf/key-bindings.zsh" \
          "/usr/local/share/fzf/shell/key-bindings.zsh" \
          "$(brew --prefix 2>/dev/null)/share/fzf/shell/key-bindings.zsh" 2>/dev/null
        do
          if [[ -f "$fzf_keybindings" ]]; then
            source "$fzf_keybindings"
            break
          fi
        done
      fi
    '';
  };
}