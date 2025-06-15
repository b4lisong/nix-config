{ config, lib, pkgs, myVars, ... }:

let
  # Import the master starship configuration from our organized configs
  starshipConfig = import ../configs/home/programs/starship.nix;
in
{
  /*
    Base Home Manager Configuration
    
    This module contains user-specific configuration that should be
    consistent across all machines, regardless of OS or architecture.
    
    Home Manager hierarchy:
    home/base.nix (this file)
    ├── home/darwin.nix
    ├── home/nixos.nix (future)
    └── host-specific home configs
    
    This parallels our system configuration hierarchy but focuses on
    user-level settings, dotfiles, and personal applications.
  */

  # Access to system variables through extraSpecialArgs
  # Variables are available as myVars.* (passed from system config)

  /*
    Essential Home Manager Settings
  */
  
  # Home Manager version - keep this in sync with your nix-darwin version
  home.stateVersion = "25.05";

  # Basic user information (should match system user config)
  home.username = myVars.user.username;
  home.homeDirectory = "/Users/${myVars.user.username}";

  /*
    User-Specific Packages
    Packages that should be available in the user's environment
    but don't need to be system-wide
  */
  home.packages = with pkgs; [
    # User-specific tools that complement system packages
    # Most packages will go in modules, this is for truly personal tools
  ];

  /*
    Program Configuration
    User-specific program settings and dotfiles
  */
  programs = {
    # Home Manager manages the user's shell configuration
    # This will generate the proper .zshenv and fix our current error
    zsh = {
      enable = true;
      
      # Basic shell options
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      
      # Shell aliases (will extend system-level aliases)
      shellAliases = {
        # Personal productivity aliases
        ".." = "cd ..";
        "..." = "cd ../..";
        
        # Reload home configuration
        "home-switch" = "home-manager switch --flake ~/.config/nix-config";
      };
      
      # Shell initialization
      initExtra = ''
        # Personal shell customizations go here
        # This runs after system shell initialization
        
        # Set up any user-specific environment
        export PERSONAL_CONFIG_DIR="$HOME/.config"
      '';
    };

    # Enable and configure starship using Home Manager's built-in module
    starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = false;

      # Use our imported starship configuration
      settings = starshipConfig;
    };

    # Git configuration (user-specific, complements system git)
    git = {
      enable = true;
      userName = myVars.git.userName;
      userEmail = myVars.git.userEmail;
      
      # User-specific git settings
      extraConfig = {
        init.defaultBranch = myVars.git.defaultBranch;
        pull.rebase = myVars.git.pullRebase;
        
        # Personal git preferences
        core.editor = myVars.preferences.editor;
        diff.tool = "vimdiff";
        merge.tool = "vimdiff";
        
        # Helpful aliases
        alias = {
          st = "status";
          co = "checkout";
          br = "branch";
          ci = "commit";
          unstage = "reset HEAD --";
          last = "log -1 HEAD";
          visual = "!gitk";
        };
      };
    };

    # Home Manager's vim configuration (complements system vim)
    vim = {
      enable = true;
      
      # User-specific vim settings and plugins can go here
      # For now, we'll rely on the system vim configuration
      extraConfig = ''
        " Additional user-specific vim configuration
        " This extends the system /etc/vimrc configuration
      '';
    };
  };

  /*
    Environment Variables
    User-specific environment variables
  */
  home.sessionVariables = {
    # Personal environment variables
    PERSONAL_WORKSPACE = "$HOME/workspace";
    
    # Development environment variables can go here
    # (will be expanded by development module)
  };

  /*
    File Management
    User-specific files and dotfiles
  */
  home.file = {
    # Example: personal configuration files
    # ".gitignore_global".source = ./dotfiles/gitignore_global;
    
    # Personal scripts directory
    ".local/bin/.keep".text = "";
  };

  /*
    XDG Base Directory Support
    Proper XDG directory structure for config/cache/data
  */
  xdg = {
    enable = true;
    
    # This creates proper ~/.config, ~/.cache, ~/.local/share directories
    # and sets appropriate environment variables
  };

  /*
    Services
    User-specific background services
    (macOS services will be handled by the darwin-specific home config)
  */
  
  # Note: Most services will be OS-specific and defined in home/darwin.nix

  /*
    Fonts
    User-specific fonts (in addition to system fonts)
  */
  fonts.fontconfig.enable = true;
}