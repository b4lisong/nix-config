{
  inputs, lib, mylib, myvars, system, genSpecialArgs, ...
}@args:
let
  name = "a2251";
  modules = {
    darwin-modules = (map mylib.relativeToRoot [
      "modules/base.nix"
      "modules/darwin"
      "hosts/darwin-${name}"
    ]) ++ [{
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