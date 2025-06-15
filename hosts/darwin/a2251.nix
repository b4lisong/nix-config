{ config, lib, pkgs, ... }:

{
  /*
    a2251 - Personal MacBook Pro (Intel x86_64)
    
    This is my primary personal machine configuration.
    It inherits from:
    - base/default.nix (common config for all machines)
    - systems/darwin/default.nix (macOS-specific config)
    - modules/coreutils.nix (rich command-line tools)
    
    Host-specific customizations:
    - Development-focused package selection
    - Personal productivity settings
    - Hardware-specific configurations
  */

  imports = [
    # Inherit base system configuration
    ../../systems/darwin/default.nix
    
    # Include desired modules
    ../../modules/coreutils.nix
  ];

  /*
    Host-Specific System Configuration
  */
  
  # Set the target platform for this specific machine
  nixpkgs.hostPlatform = config.myVars.hosts.a2251.system;  # "x86_64-darwin"

  # Set hostname to match our variables
  networking.hostName = config.myVars.hosts.a2251.hostname;  # "a2251"

  /*
    Host-Specific Package Selection
    
    Additional packages beyond what's provided by base config and modules.
    These are specific to your personal development workflow.
  */
  environment.systemPackages = with pkgs; [
    # Development tools (will later move to development module)
    lazygit           # Git TUI for better git workflow
    
    # Personal productivity tools
    # (Add other tools specific to this machine as needed)
  ];

  /*
    Host-Specific System Settings
    
    Override or extend the Darwin defaults for this specific machine.
  */
  system = {
    # Link the configuration revision to our flake
    configurationRevision = null;  # This will be set by the flake
    
    defaults = {
      # Host-specific dock configuration
      dock = {
        # Override the default persistent apps for this machine
        persistent-apps = [
          "/Applications/Safari.app"
          "/Applications/Cursor.app"
          # Add other apps specific to your workflow
        ];
      };
      
      # Any other host-specific macOS settings can go here
    };
  };

  /*
    Host-Specific User Configuration
    
    Any user account settings specific to this machine.
  */
  users.users.${config.myVars.user.username} = {
    # All basic user config comes from base and darwin configs
    # Add host-specific user settings here if needed
  };

  /*
    Host-Specific Services
    
    Services that should only run on this specific machine.
  */
  # Example: development databases, specific daemons, etc.
  # services.someService.enable = true;

  /*
    Host-Specific Environment Variables
    
    Environment variables specific to this development machine.
  */
  environment.variables = {
    # Example: machine-specific paths, development settings
    # DEVELOPMENT_MODE = "true";
  };

  /*
    Comments for Future Configuration
    
    Areas where this host configuration might grow:
    
    1. Home Manager Integration:
       - Personal dotfiles and configurations
       - Development environment setup
       - Application-specific settings
    
    2. Development Environment:
       - Programming language tools
       - IDE/editor configurations
       - Project-specific tooling
    
    3. Hardware-Specific Settings:
       - Display configuration
       - Audio settings
       - External hardware support
    
    4. Security and Privacy:
       - Personal encryption settings
       - VPN configurations
       - Firewall rules

    5. Creative/fun applications:
       - Gaming
       - DJ/Music prod.
       - Random bullshit
  */
}