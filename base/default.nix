{ config, lib, pkgs, ... }:

let
  # Import our shared variables
  vars = import ../variables.nix;
in
{
  /*
    Base Configuration - Foundation for All Machines
    
    This module contains the absolute minimum configuration that should
    be present on every machine, regardless of OS or architecture.
    
    Inheritance hierarchy:
    base/default.nix (this file)
    ├── systems/darwin/default.nix
    ├── systems/nixos/default.nix
    └── hosts/*

    All machines inherit these settings and can override them as needed.
  */

  # Make variables available to all other modules
  options.myVars = lib.mkOption {
    type = lib.types.attrs;
    default = vars;
    description = "Shared configuration variables";
  };

  config = {
    # Set the shared variables
    myVars = vars;

    /*
      Nix Configuration
      Essential Nix settings that should be consistent across all machines
    */
    nix = {
      # Enable flakes and the new nix command interface
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        
        # Optimize store and enable auto-optimization
        auto-optimise-store = true;
      };
      
      # Garbage collection - keep system clean
      gc = {
        automatic = true;
        # Frequency will be set per-OS (daily on Darwin, weekly on NixOS)
        options = "--delete-older-than 30d";
      };
    };

    /*
      Nixpkgs Configuration
      Settings that affect how packages are built and selected
    */
    nixpkgs.config = {
      # Allow unfree/proprietary software
      allowUnfree = true;
    };

    /*
      Essential System Packages
      The absolute minimum packages that should be available on every machine
    */
    environment.systemPackages = with pkgs; [
      # Basic system tools
      curl              # HTTP client
      wget              # File downloader
      git               # Version control (essential for nix flakes)
      
      # Text processing
      vim               # Basic editor (always available as fallback)
      
      # System information
      htop              # Process viewer
      tree              # Directory visualization
      
      # Archive tools
      unzip             # Archive extraction
      zip               # Archive creation
      
      # Shell and prompt
      zsh               # Modern shell
      starship          # Cross-shell prompt
    ];

    /*
      Environment Variables
      Global environment settings that should be consistent
    */
    environment.variables = {
      # Default editor
      EDITOR = vars.preferences.editor;
      VISUAL = vars.preferences.editor;
      
      # Improve nix command output
      NIXPKGS_ALLOW_UNFREE = "1";
      
      # Set vim to use system vimrc
      VIMINIT = "source /etc/vimrc";
      
      # Set starship config path
      STARSHIP_CONFIG = "/etc/starship.toml";
    };

    /*
      System Configuration Files
      Create configuration files for programs that don't have dedicated
      nix-darwin program options.
    */
    environment.etc = {
      # Vim configuration
      "vimrc".text = ''
        " Essential vim settings
        set expandtab         " Use spaces instead of tabs
        set tabstop=4         " Number of spaces per indentation level
        set shiftwidth=4      " Number of spaces for automatic indentation
        set number            " Show line numbers
        
        " Basic usability settings
        set softtabstop=4
        set autoindent
        syntax on
        filetype plugin indent on
        set cursorline
        set incsearch
        
        " Search highlighting that only shows during search
        augroup vimrc-incsearch-highlight
          autocmd!
          autocmd CmdlineEnter [/\?] :set hlsearch
          autocmd CmdlineLeave [/\?] :set nohlsearch
        augroup END
        
        " Custom key bindings for faster vertical movement
        " J moves down 5 lines, K moves up 5 lines
        nnoremap J 5j
        nnoremap K 5k
        
        " Map 'jk' to ESC for faster mode switching
        inoremap jk <Esc>
      '';

      # Starship configuration
      "starship.toml".text = ''
        # Basic starship configuration for all machines
        add_newline = true
        
        # Simple format - can be enhanced in modules or home manager
        format = "$all$character"
        
        [character]
        success_symbol = "[❯](bold green)"
        error_symbol = "[✗](bold red)"
        
        # Show git information when in git repos
        [git_branch]
        disabled = false
        
        [git_status]
        disabled = false
      '';
    };

    /*
      User Account Configuration
      Set up the primary user account with basic settings
    */
    users.users.${vars.user.username} = {
      description = vars.user.fullName;
      shell = pkgs.${vars.user.shell};
      
      # Additional user configuration will be added by OS-specific modules
      # Darwin: home directory, uid, etc.
      # NixOS: isNormalUser, extraGroups, etc.
    };

    /*
      Program Configuration
      Start with minimal nix-darwin supported options
    */
    programs = {
      # Zsh - very basic configuration to test
      zsh.enable = true;

      # Vim - minimal configuration since nix-darwin has limited vim options
      vim.enable = true;
    };
  };
}