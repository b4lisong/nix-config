{
  inputs, lib, mylib, myvars, system, genSpecialArgs, ...
}@args:
let
  name = "rpi4b";
  modules = {
    nixos-modules = (map mylib.relativeToRoot [
      "modules/base.nix"
      "modules/nixos"
      "modules/nixos/raspberry-pi.nix"
      "modules/nixos/docker.nix"
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