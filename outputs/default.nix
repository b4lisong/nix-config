{
  self,
  nixpkgs,
  nixpkgs-unstable,
  nix-darwin,
  home-manager,
  haumea,
  ...
}@inputs:
let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib { inherit lib; };
  myvars = import ../variables;  # OUR variables, not ../vars

  # Generate specialArgs for each system
  genSpecialArgs = system: inputs // {
    inherit mylib myvars;
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };

  # Common args for all architectures
  args = {
    inherit inputs lib mylib myvars genSpecialArgs;
  };

  # Architecture-specific modules
  nixosSystems = {
    x86_64-linux = import ./x86_64-linux (args // { system = "x86_64-linux"; });
    aarch64-linux = import ./aarch64-linux (args // { system = "aarch64-linux"; });
  };
  darwinSystems = {
    x86_64-darwin = import ./x86_64-darwin (args // { system = "x86_64-darwin"; });
    aarch64-darwin = import ./aarch64-darwin (args // { system = "aarch64-darwin"; });
  };

  allSystems = nixosSystems // darwinSystems;
  allSystemNames = builtins.attrNames allSystems;
  nixosSystemValues = builtins.attrValues nixosSystems;
  darwinSystemValues = builtins.attrValues darwinSystems;
  allSystemValues = nixosSystemValues ++ darwinSystemValues;

  # Helper for generating attributes across all systems
  forAllSystems = func: (nixpkgs.lib.genAttrs allSystemNames func);
in
{
  # Add attribute sets into outputs, for debugging
  debugAttrs = {
    inherit
      nixosSystems
      darwinSystems
      allSystems
      allSystemNames
      ;
  };

  # NixOS Configurations
  nixosConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.nixosConfigurations or { }) nixosSystemValues
  );

  # macOS Configurations
  darwinConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.darwinConfigurations or { }) darwinSystemValues
  );

  # Packages
  packages = forAllSystems (system: allSystems.${system}.packages or { });

  # Development Shells
  devShells = forAllSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          alejandra
          pre-commit
          statix
          deadnix
          nix-tree
          manix
          nil
          jq
          git
          lua-language-server
          stylua
          selene
        ];
      };
    });

  # Formatter
  formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
}