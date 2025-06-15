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
        
        # Allow unfree packages (for things like Discord, Spotify, etc.)
        # This will be inherited by nixpkgs.config.allowUnfree
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
      
      # Allow packages with broken/insecure status if needed
      # (Usually not needed, but can be enabled per-host if required)
      # allowBroken = false;
      # allowInsecure = false;
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
      Global Program Configuration
      Basic program settings that should be consistent across all machines
      
      Note: nix-darwin has limited system-level program options compared to NixOS.
      Many configurations are handled via shell initialization or Home Manager.
    */
    programs = {
      # Zsh - Modern shell with basic configuration
      zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        
        # Basic shell options that improve usability
        setOptions = [
          "autocd"              # Change directory just by typing its name
          "interactivecomments" # Allow comments in interactive mode
          "magicequalsubst"     # Enable filename expansion for arguments
          "nonomatch"           # Hide error message if no match for pattern
          "notify"              # Report status of background jobs immediately
          "numericglobsort"     # Sort filenames numerically when it makes sense
          "promptsubst"         # Enable command substitution in prompt
        ];

        # Essential aliases that should be available everywhere
        shellAliases = {
          # Force zsh to show complete history
          history = "history 0";
          
          # Useful ls aliases
          ll = "ls -l";
          la = "ls -alh";
          l = "ls -CF";
          
          # Basic git shortcuts
          gs = "git status";
          ga = "git add";
          gc = "git commit";
          gp = "git pull";
          gP = "git push";
          gd = "git diff";
          gdc = "git diff --cached";
        };

        # History configuration
        history = {
          size = 1000;
          save = 2000;
          ignoreDups = true;
          ignoreSpace = true;
          expireDuplicatesFirst = true;
        };

        # Shell initialization for git configuration and starship
        interactiveShellInit = ''
          # Configure git globally
          git config --global init.defaultBranch "${vars.git.defaultBranch}"
          git config --global pull.rebase ${if vars.git.pullRebase then "true" else "false"}
          git config --global user.name "${vars.git.userName}"
          git config --global user.email "${vars.git.userEmail}"
          
          # Initialize starship prompt if available
          if command -v starship >/dev/null 2>&1; then
            eval "$(starship init zsh)"
          fi
        '';
      };

      # Vim - Basic editor configuration that works everywhere
      vim = {
        enable = true;
        
        # Essential vim settings
        settings = {
          expandtab = true;     # Use spaces instead of tabs
          tabstop = 4;          # Number of spaces per indentation level
          shiftwidth = 4;       # Number of spaces for automatic indentation
          number = true;        # Show line numbers
        };

        # Basic vim configuration
        extraConfig = ''
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
      };
    };

    /*
      Starship Configuration
      
      Since nix-darwin doesn't have programs.starship, we configure it via
      environment variables and config files.
    */
    environment.etc."starship.toml".text = ''
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

    # Set starship config path
    environment.variables.STARSHIP_CONFIG = "/etc/starship.toml";

    /*
      Security and Privacy
      Basic security settings that should apply everywhere
    */
    # This section will be expanded by OS-specific configurations
    
    /*
      Placeholder for future base configuration
      Items that might be added here later:
      - Common aliases and shell configuration
      - Basic networking settings
      - Shared directory structure
      - Common environment variables
    */
  };
}