{ config, lib, pkgs, ... }:

{
  /*
    Darwin (macOS) Home Manager Configuration
    
    This module contains macOS-specific user configuration that builds
    upon the base home manager configuration.
    
    Inheritance hierarchy:
    home/base.nix → home/darwin.nix (this file) → host home configs
  */

  # Import the base home configuration
  imports = [
    ./base.nix
  ];

  /*
    macOS-Specific User Packages
    GUI applications and tools that are specific to macOS
  */
  home.packages = with pkgs; [
    # macOS-specific command line tools
    # (Most GUI apps are handled via Homebrew in system config)
    
    # Development tools that work well on macOS
    # (Will be expanded by development module)
  ];

  /*
    macOS-Specific Program Configuration
  */
  programs = {
    # macOS-specific shell configuration
    zsh = {
      # Add macOS-specific aliases
      shellAliases = {
        # macOS system shortcuts
        "show-hidden" = "defaults write com.apple.finder AppleShowAllFiles true && killall Finder";
        "hide-hidden" = "defaults write com.apple.finder AppleShowAllFiles false && killall Finder";
        
        # Quick access to common macOS locations
        "desktop" = "cd ~/Desktop";
        "downloads" = "cd ~/Downloads";
        "documents" = "cd ~/Documents";
        
        # macOS clipboard integration
        "pbcopy" = "pbcopy";
        "pbpaste" = "pbpaste";
      };
      
      # macOS-specific shell initialization
      initExtra = ''
        # macOS-specific shell setup
        
        # Add personal bin to PATH if it exists
        if [[ -d "$HOME/.local/bin" ]]; then
          export PATH="$HOME/.local/bin:$PATH"
        fi
        
        # macOS-specific environment setup
        export BROWSER="open"
      '';
    };
  };

  /*
    macOS-Specific Environment Variables
  */
  home.sessionVariables = {
    # macOS-specific paths and settings
    BROWSER = "open";
    
    # macOS development environment
    # (will be expanded by development module)
  };

  /*
    macOS-Specific Files and Dotfiles
  */
  home.file = {
    # macOS-specific configuration files can go here
    # Example: ".hushlogin" to suppress login message
    # ".hushlogin".text = "";
  };

  /*
    macOS Integration
    Settings that integrate with macOS system features
  */
  
  # Note: Most macOS system integration is handled by the system configuration
  # This section is for user-specific macOS integrations

  /*
    Application Support
    Support for macOS applications and workflows
  */
  
  # This can be expanded later to include:
  # - Dock preferences (user-specific)
  # - Finder preferences (user-specific) 
  # - Application-specific user configs
  # - Workflow automations
}