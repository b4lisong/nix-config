args:
with args;
with allSystemAttrs; let
  inherit (nixpkgs) lib;
  macosSystem = import ../lib/macosSystem.nix;
  base_args = {
    inherit nix-darwin home-manager;
    nixpkgs = nixpkgs-darwin;
  };
in {
  # macOS's configuration
  darwinConfigurations = {
    harmonica = macosSystem (
      lib.attrsets.mergeAttrsList [
        base_args
        darwin_harmonica_modules
        {
          system = allSystemAttrs.x64_darwin;
          specialArgs = allSystemSpecialArgs.x64_darwin;
        }
      ]
    );

    fern = macosSystem (
      lib.attrsets.mergeAttrsList [
        base_args
        darwin_fern_modules
        {
          system = aarch64_darwin;
          specialArgs = allSystemSpecialArgs.aarch64_darwin;
        }
      ]
    );
  };
}