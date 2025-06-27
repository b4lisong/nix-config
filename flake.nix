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
  # = inputs@{ ... } destructures inputs while keeping full set as `inputs`
  #   `self` refers to this flake itself
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
    mkDarwinHost = hostName: {
      modules = [
        # `modules` array defines what gets included in each system
        ./modules/base.nix # shared base config, all machines
        ./modules/darwin # Darwin-specific modules
        ./hosts/${hostName}/system.nix # Host-specific system configuration
        home-manager.darwinModules.home-manager # integrates Home Manager
        {
          home-manager.users.${vars.user.username}.imports = [
            ./hosts/${hostName}/home.nix # import host-specific HM config
          ];
          # Pass pkgs-unstable to home-manager modules
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
    # Create Nix development environments for all supported systems
    devShells = forAllSystems (system: {default = mkDevShell system;});
  };
}
