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
  };

  # Main function that generates what this flake provides
  # This function takes the declared inputs and produces the flake outputs
  # = inputs@{ ... } destructures inputs while keeping full set as `inputs`
  #   `self` refers to this flake itself for accessing git revision info
  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-darwin,
    home-manager,
  }: let
    # Local variable setup, defines local vars used throughout flake
    # `lib` imports custom utilities which extend nixpkgs lib
    # `modules.nix` contains helper functions for module import
    lib = import ./lib/modules.nix {inherit (nixpkgs) lib;};
    # `vars` imports shared vars/constants (usernames, host configs, etc.)
    vars = import ./variables;
    # Helper function that creates a Darwin system config for a given hostname
    # This function encapsulates the entire system assembly process:
    # 1. System-level configuration (modules/base.nix + modules/darwin)
    # 2. Host-specific system configuration (hosts/<hostname>/system.nix)
    # 3. Home Manager integration with user-level configuration
    # 4. Makes both stable and unstable packages available to all modules
    mkDarwinHost = hostName: {
      modules = [
        # System configuration hierarchy (applied in order):
        # 1. Base system configuration (shared across all platforms)
        ./modules/base.nix # Core packages, fonts, Nix settings for all systems

        # 2. Platform-specific system configuration
        ./modules/darwin # macOS-specific settings, Homebrew, system defaults

        # 3. Host-specific system configuration
        ./hosts/${hostName}/system.nix # Machine-specific overrides and additions

        # 4. Home Manager integration as a nix-darwin module
        home-manager.darwinModules.home-manager # Enables user-level configuration
        {
          # Home Manager user configuration
          home-manager.users.${vars.user.username}.imports = [
            ./hosts/${hostName}/home.nix # Host-specific user config (profiles + roles)
          ];

          # Provide unstable packages to Home Manager modules
          # This enables using bleeding-edge packages in user configuration
          home-manager.extraSpecialArgs = {
            pkgs-unstable = import nixpkgs-unstable {
              system = vars.hosts.${hostName}.system;
              config.allowUnfree = true;
            };
          };
        }
      ];
      # `specialArgs` passes additional arguments to all modules
      specialArgs = {
        inherit self inputs vars;
        # Make unstable pkgs available to all modules via pkgs-unstable
        pkgs-unstable = import nixpkgs-unstable {
          system = vars.hosts.${hostName}.system;
          config.allowUnfree = true;
        };
      };
    };
    # Declare supported architectures
    # TODO: aarch64-linux
    systems = ["x86_64-darwin" "aarch64-darwin"];
    # `forAllSystems` creates a helper to generate attrs for each supported system
    forAllSystems = nixpkgs.lib.genAttrs systems;
    # `nixpkgsFor` gets the nixpkgs package set for a specific system arch
    nixpkgsFor = system: nixpkgs.legacyPackages.${system};
    # `mkDevShell` creates a development env for a given system
    mkDevShell = system: let
      pkgs = nixpkgsFor system;
      # Also make unstable pkgs available in dev shells
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
      pkgs.mkShell {
        buildInputs = with pkgs;
          [
            alejandra # Nix code formatter
            pre-commit # pre-commit automation
            statix # Nix linter
            deadnix # finds unused Nix code
            nix-tree # visualize Nix store dependencies
            manix # searches Nix docs
            nil # Nix language server
            jq # JSON processor
            git # Version control
            # Lua development tools for neovim configuration
            lua-language-server # Lua LSP support
            stylua # Lua code formatter
            selene # Lua linter
          ]
          ++ [
            # Example unstable pkgs for development
            # pkgs-unstable.nodejs_24
            # pkgs-unstable.bun
          ];
      };
  in {
    # Begin actual outputs definition
    # Create a Darwin system config using the `a2251` host variables
    darwinConfigurations.${vars.hosts.a2251.hostname} =
      nix-darwin.lib.darwinSystem (mkDarwinHost vars.hosts.a2251.hostname);

    # Create a Darwin system config using the `sksm3` host variables
    darwinConfigurations.${vars.hosts.sksm3.hostname} =
      nix-darwin.lib.darwinSystem (mkDarwinHost vars.hosts.sksm3.hostname);
    # Create Nix development environments for all supported systems
    devShells = forAllSystems (system: {default = mkDevShell system;});
  };
}
