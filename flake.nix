/*
FLAKE.NIX - Main Configuration Entry Point

This flake provides a modular, cross-platform Nix configuration supporting
both macOS (via nix-darwin) and future NixOS systems. It implements a
layered architecture with clear separation of concerns.

ARCHITECTURE OVERVIEW:

System Configuration Layers (applied bottom-to-top):
1. Base Layer (modules/base.nix):
   - Core system packages (vim, git, archives, networking tools)
   - Essential fonts (Nerd Fonts, emoji, programming fonts)
   - Nix settings (experimental features, unfree packages)

2. Platform Layer (modules/darwin/ or modules/nixos/):
   - Platform-specific system configuration
   - Darwin: macOS defaults, Touch ID, Homebrew integration
   - NixOS: Hardware, systemd services, desktop environments

3. Host Layer (hosts/<hostname>/system.nix):
   - Machine-specific system configuration
   - Host-specific Homebrew packages
   - Hardware-specific settings and overrides

User Configuration Layers (Home Manager):
4. Profile Layer (home/profiles/):
   - base: Core CLI tools and git configuration
   - tui: Terminal applications (btop, gping, yazi, etc.)
   - gui: Cross-platform desktop applications
   - darwin: macOS-specific applications and optimizations

5. Role Layer (home/roles/):
   - dev: Development tools (neovim, nodejs, claude-code)
   - personal: Entertainment and personal apps
   - work: Work-specific tools and compliance
   - security: Security and penetration testing tools
   - docker: Container and orchestration tools

6. Host Layer (hosts/<hostname>/home.nix):
   - Host-specific user configuration
   - Combines profiles and roles for complete environment
   - Machine-specific overrides and customizations

DUAL PACKAGE SYSTEM:
- nixpkgs: Stable packages for reliability
- nixpkgs-unstable: Bleeding-edge packages for development
- Both available to all modules via specialArgs

CONFIGURATION FLOW:
flake.nix → mkDarwinHost() → system modules → Home Manager → user profiles/roles

VARIABLES SYSTEM:
- Centralized in variables/default.nix
- User info, git settings, host metadata
- Shared across all configuration layers
- Enables consistent configuration

This architecture provides:
- Modular, composable configuration
- Clear separation between system and user levels
- Platform independence with specific optimizations
- Role-based package organization
- Reproducible, declarative system management
*/
{
  description = "Modular nix{-darwin,OS} config";

  # Declare external dependencies needed by this flake
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin"; # stable pkgs
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; # bleeding-edge pkgs
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs"; # nix-darwin nixpkgs version = nixpkgs version
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs"; # home-manager nixpkgs version = nixpkgs version

    # Haumea for automatic module discovery
    haumea.url = "github:nix-community/haumea/v0.2.2";
    haumea.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Main function that generates what this flake provides
  # This function takes the declared inputs and produces the flake outputs
  # = inputs@{ ... } destructures inputs while keeping full set as `inputs`
  #   `self` refers to this flake itself for accessing git revision info
  # Simplified outputs - delegates to outputs/default.nix
  outputs = inputs: import ./outputs inputs;
}
