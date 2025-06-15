{
  description = "Modular Nix{OS,-darwin} system flake with inheritance hierarchy";

  /*
    Input Dependencies
    
    We pin specific versions to ensure reproducibility:
    - nixpkgs: Main package repository (Darwin-optimized branch)
    - nix-darwin: macOS system configuration management
    - home-manager: User-specific package and dotfile management
  */
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    # Import our shared variables for easy access
    vars = import ./variables.nix;
    
    # System-agnostic configuration
    systems = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
    
    # Helper to create package sets for each system
    forAllSystems = nixpkgs.lib.genAttrs systems;
    
    # Get nixpkgs for a specific system
    nixpkgsFor = system: nixpkgs.legacyPackages.${system};

    /*
      Development Shell Factory Function
      Creates a development shell for any system (for working on this nix-config)
    */
    mkDevShell = system:
      let pkgs = nixpkgsFor system;
      in pkgs.mkShell {
        buildInputs = with pkgs; [
          # Nix development tools
          nixpkgs-fmt      # Format .nix files
          statix           # Linter for Nix
          deadnix          # Find unused Nix code
          nix-tree         # Visualize dependency trees
          manix            # Search Nix documentation
          nil              # Nix LSP
          
          # Helpful utilities for config work
          jq               # JSON processing (for flake.lock)
          git              # Version control
        ];
        
        shellHook = ''
          echo "🔧 Nix Configuration Development Environment"
          echo "Working on: $(basename $PWD)"
          echo "Available hosts:"
          echo "  a2251  - Personal MacBook Pro (x86_64-darwin)"
          echo "  sksm3  - Work MacBook (x86_64-darwin) [future]"
          echo "  rpi4b  - Raspberry Pi 4B (aarch64-linux) [future]"
          echo ""
          echo "Available tools:"
          echo "  nixpkgs-fmt  - Format Nix files"
          echo "  statix       - Lint Nix files"
          echo "  deadnix      - Find dead code"
          echo "  manix        - Search Nix docs"
          echo ""
          echo "Useful commands:"
          echo "  sudo darwin-rebuild switch --flake .#a2251"
          echo "  sudo darwin-rebuild check --flake .#a2251"
          echo "  sudo darwin-rebuild --list-generations"
          echo "  nix flake update"
          echo ""
          
          # Set up convenient aliases (only in this dev shell)
          alias rebuild="sudo darwin-rebuild switch --flake .#a2251"
          alias check="sudo darwin-rebuild check --flake .#a2251"
          alias update="nix flake update"
          alias fmt="nixpkgs-fmt *.nix **/*.nix"
          alias lint="statix check ."
        '';
      };
  in
  {
    /*
      Darwin System Configuration Outputs
      
      Each Darwin host gets its own configuration that follows our
      inheritance hierarchy: base → systems/darwin → modules → host
    */
    darwinConfigurations = {
      # Personal MacBook Pro (Intel)
      a2251 = nix-darwin.lib.darwinSystem {
        system = vars.hosts.a2251.system;  # "x86_64-darwin"
        modules = [ 
          # The host configuration handles all inheritance
          ./hosts/darwin/a2251.nix
          
          # Import Home Manager module
          home-manager.darwinModules.home-manager
          
          # Set the configuration revision for system tracking
          {
            system.configurationRevision = self.rev or self.dirtyRev or null;
          }
        ];
      };

      # Work MacBook (placeholder for future)
      sksm3 = nix-darwin.lib.darwinSystem {
        system = vars.hosts.sksm3.system;  # "x86_64-darwin"
        modules = [ 
          # Will create this file in a future step
          # ./hosts/darwin/sksm3.nix
          
          # Import Home Manager module
          home-manager.darwinModules.home-manager
          
          # Temporary minimal config for testing
          {
            imports = [ ./systems/darwin/default.nix ];
            nixpkgs.hostPlatform = vars.hosts.sksm3.system;
            networking.hostName = vars.hosts.sksm3.hostname;
            system.configurationRevision = self.rev or self.dirtyRev or null;
          }
        ];
      };
    };

    # Future: NixOS configurations will go here
    # nixosConfigurations = {
    #   rpi4b = nixpkgs.lib.nixosSystem {
    #     system = vars.hosts.rpi4b.system;  # "aarch64-linux"
    #     modules = [ ./hosts/nixos/rpi4b.nix ];
    #   };
    # };

    /*
      Development Shells for All Systems
      This creates development environments for working on the nix-config itself
    */
    devShells = forAllSystems (system: {
      default = mkDevShell system;
    });

    /*
      Expose our variables for debugging and introspection
    */
    lib = {
      inherit vars;
    };
  };
}