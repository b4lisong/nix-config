{
  inputs, lib, mylib, myvars, system, genSpecialArgs, ...
}@args:
let
  name = "k3s-c-vm";
  modules = {
    nixos-modules = (map mylib.relativeToRoot [
      "modules/base.nix"
      "modules/nixos"
      "hosts/linux-${name}"
    ]) ++ [{
      nixpkgs.hostPlatform = system;
    }];
    home-modules = map mylib.relativeToRoot [
      "hosts/linux-${name}/home.nix"
    ];
  };
  systemArgs = modules // args;
in
{
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;
}