{
  inputs,
  lib,
  mylib,
  myvars,
  system,
  genSpecialArgs,
  ...
}@args:
let
  name = "sksm3";

  modules = {
    darwin-modules = (map mylib.relativeToRoot [
      "modules/base.nix"      # System packages
      "modules/darwin"        # macOS configuration
      "hosts/darwin-${name}"  # Host-specific config
    ]) ++ [{
      # Inline module for things that were in system.nix
      nixpkgs.hostPlatform = system;
      system.primaryUser = myvars.user.username;
    }];

    home-modules = map mylib.relativeToRoot [
      "hosts/darwin-${name}/home.nix"
    ];
  };

  systemArgs = modules // args;
in
{
  darwinConfigurations.${name} = mylib.macosSystem systemArgs;
}