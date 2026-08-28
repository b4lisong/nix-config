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

  # Nixpkgs 26.11 dropped x86_64-darwin, and the removal is a hard throw at
  # import time rather than a per-package failure -- importing nixpkgs-unstable
  # with system = "x86_64-darwin" aborts evaluation outright. The Intel host
  # (darwin-a2251, the only x86_64-darwin host) therefore sources its
  # "unstable" set from stable 26.05, which carries newer Go than the last
  # pre-drop unstable (1.26.6 vs 1.26.3) and keeps receiving security fixes
  # until 26.05 goes out of support at the end of 2026. Every other host keeps
  # tracking nixpkgs-unstable normally.
  unstableFor =
    system: if system == "x86_64-darwin" then inputs.nixpkgs else inputs.nixpkgs-unstable;

  # Generate specialArgs for each system
  genSpecialArgs = system: inputs // {
    inherit mylib myvars;
    pkgs-unstable = import (unstableFor system) {
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